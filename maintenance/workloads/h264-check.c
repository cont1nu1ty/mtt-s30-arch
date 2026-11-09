/* SPDX-License-Identifier: MIT
 * Force VAAPI frames, download NV12, and compare every byte with a software
 * reference. The get_format callback explicitly refuses software fallback.
 */
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libavutil/hwcontext.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define WIDTH 320
#define HEIGHT 192
#define FRAMES 48
#define FRAME_BYTES (WIDTH * HEIGHT * 3 / 2)
#define REQUIRE(c,msg) do {if (!(c)) {fprintf(stderr,"%s\n",msg);exit(2);}} while (0)
#define AV(call) do {int r_=(call);if(r_<0){char e_[AV_ERROR_MAX_STRING_SIZE]; \
 av_strerror(r_,e_,sizeof e_);fprintf(stderr,"%s: %s\n",#call,e_);exit(2);}} while (0)

static enum AVPixelFormat vaapi_only(AVCodecContext *ctx, const enum AVPixelFormat *formats)
{
    (void)ctx;
    for (;*formats != AV_PIX_FMT_NONE;formats++)
        if (*formats == AV_PIX_FMT_VAAPI) return *formats;
    fprintf(stderr,"Decoder did not offer VAAPI; software fallback refused\n");
    return AV_PIX_FMT_NONE;
}

struct results {
    unsigned frames, hardware_frames, bad_frames, max_error;
    uint64_t different_bytes;
    FILE *reference, *actual;
    int software;
};

static int receive(AVCodecContext *decoder, struct results *r)
{
    AVFrame *frame=av_frame_alloc(), *cpu=av_frame_alloc();
    REQUIRE(frame && cpu,"Cannot allocate frames");
    int code;
    while ((code=avcodec_receive_frame(decoder,frame)) >= 0) {
        REQUIRE(r->frames < FRAMES,"Unexpected extra decoded frame");
        REQUIRE(frame->width==WIDTH && frame->height==HEIGHT,"Unexpected frame geometry");
        AVFrame *pixels=frame;
        if (!r->software) {
            REQUIRE(frame->format==AV_PIX_FMT_VAAPI && frame->hw_frames_ctx,
                    "A decoded frame was not VAAPI hardware output");
            r->hardware_frames++;
            cpu->format=AV_PIX_FMT_NV12;
            AV(av_hwframe_transfer_data(cpu,frame,0));
            pixels=cpu;
        }
        REQUIRE(pixels->format==AV_PIX_FMT_NV12 || pixels->format==AV_PIX_FMT_YUV420P,
                "Unexpected downloaded/software pixel format");
        uint8_t actual[FRAME_BYTES], expected[FRAME_BYTES];
        REQUIRE(pixels->linesize[0]>=WIDTH,"Invalid luma stride");
        for (int y=0;y<HEIGHT;y++)
            memcpy(actual+y*WIDTH,pixels->data[0]+y*pixels->linesize[0],WIDTH);
        if (pixels->format==AV_PIX_FMT_NV12) {
            REQUIRE(pixels->linesize[1]>=WIDTH,"Invalid NV12 chroma stride");
            for (int y=0;y<HEIGHT/2;y++)
                memcpy(actual+WIDTH*HEIGHT+y*WIDTH,pixels->data[1]+y*pixels->linesize[1],WIDTH);
        } else {
            REQUIRE(pixels->linesize[1]>=WIDTH/2 && pixels->linesize[2]>=WIDTH/2,"Invalid planar chroma stride");
            for (int y=0;y<HEIGHT/2;y++) for (int x=0;x<WIDTH/2;x++) {
                actual[WIDTH*HEIGHT+y*WIDTH+2*x]=pixels->data[1][y*pixels->linesize[1]+x];
                actual[WIDTH*HEIGHT+y*WIDTH+2*x+1]=pixels->data[2][y*pixels->linesize[2]+x];
            }
        }
        REQUIRE(fread(expected,1,FRAME_BYTES,r->reference)==FRAME_BYTES,"Reference is truncated");
        REQUIRE(fwrite(actual,1,FRAME_BYTES,r->actual)==FRAME_BYTES,"Cannot save decoded frame");
        unsigned differences=0;
        for (unsigned i=0;i<FRAME_BYTES;i++) if(actual[i]!=expected[i]) {
            unsigned delta=actual[i]>expected[i] ? actual[i]-expected[i] : expected[i]-actual[i];
            if(delta>r->max_error) r->max_error=delta;
            differences++;
        }
        if(differences) r->bad_frames++;
        r->different_bytes+=differences;
        r->frames++;
        av_frame_unref(cpu);av_frame_unref(frame);
    }
    av_frame_free(&cpu);av_frame_free(&frame);
    REQUIRE(code==AVERROR(EAGAIN) || code==AVERROR_EOF,"Unexpected decoder receive error");
    return code;
}

int main(int argc, char **argv)
{
    REQUIRE(argc==5,"Usage: h264-check /dev/dri/renderDxxx|--software-check clip.h264 reference.nv12 output.nv12");
    struct results result={.software=!strcmp(argv[1],"--software-check")};
    result.reference=fopen(argv[3],"rb");result.actual=fopen(argv[4],"wb");
    REQUIRE(result.reference && result.actual,"Cannot open input/output data");
    AVFormatContext *format=NULL;
    AV(avformat_open_input(&format,argv[2],NULL,NULL));
    AV(avformat_find_stream_info(format,NULL));
    int stream=av_find_best_stream(format,AVMEDIA_TYPE_VIDEO,-1,-1,NULL,0);
    REQUIRE(stream>=0 && format->streams[stream]->codecpar->codec_id==AV_CODEC_ID_H264,
            "Expected an H.264 video stream");
    const AVCodec *codec=avcodec_find_decoder(AV_CODEC_ID_H264);
    REQUIRE(codec,"H.264 decoder missing");
    AVCodecContext *decoder=avcodec_alloc_context3(codec);
    REQUIRE(decoder,"Cannot allocate decoder");
    AV(avcodec_parameters_to_context(decoder,format->streams[stream]->codecpar));
    decoder->thread_count=1;
    decoder->err_recognition=AV_EF_EXPLODE;
    AVBufferRef *hardware=NULL;
    if (!result.software) {
        REQUIRE(!strncmp(argv[1],"/dev/dri/renderD",16),"Expected an explicit DRM render node");
        int supported=0;
        for(int i=0;;i++) {
            const AVCodecHWConfig *cfg=avcodec_get_hw_config(codec,i);
            if(!cfg)break;
            if(cfg->device_type==AV_HWDEVICE_TYPE_VAAPI &&
               (cfg->methods & AV_CODEC_HW_CONFIG_METHOD_HW_DEVICE_CTX))supported=1;
        }
        REQUIRE(supported,"FFmpeg H.264 VAAPI device context unsupported");
        AV(av_hwdevice_ctx_create(&hardware,AV_HWDEVICE_TYPE_VAAPI,argv[1],NULL,0));
        decoder->hw_device_ctx=av_buffer_ref(hardware);
        REQUIRE(decoder->hw_device_ctx,"Cannot reference VAAPI device");
        decoder->get_format=vaapi_only;
    }
    AV(avcodec_open2(decoder,codec,NULL));
    AVPacket *packet=av_packet_alloc();REQUIRE(packet,"Cannot allocate packet");
    int read_result;
    while((read_result=av_read_frame(format,packet))>=0) {
        if(packet->stream_index==stream) {
            AV(avcodec_send_packet(decoder,packet));
            receive(decoder,&result);
        }
        av_packet_unref(packet);
    }
    REQUIRE(read_result==AVERROR_EOF,"Demuxing failed before EOF");
    AV(avcodec_send_packet(decoder,NULL));
    REQUIRE(receive(decoder,&result)==AVERROR_EOF,"Decoder did not drain to EOF");
    REQUIRE(fgetc(result.reference)==EOF && !ferror(result.reference),"Unexpected reference tail/error");
    REQUIRE(!fclose(result.actual),"Cannot close decoded output");fclose(result.reference);
    int passed=result.frames==FRAMES && result.bad_frames==0 &&
        (result.software || result.hardware_frames==FRAMES);
    printf("{\"passed\":%s,\"mode\":\"%s\",\"frames\":%u,\"hardware_frames\":%u,"
           "\"bad_frames\":%u,\"different_bytes\":%llu,\"max_abs_error\":%u}\n",
           passed?"true":"false",result.software?"software-check":"vaapi",result.frames,
           result.hardware_frames,result.bad_frames,(unsigned long long)result.different_bytes,result.max_error);
    av_packet_free(&packet);avcodec_free_context(&decoder);av_buffer_unref(&hardware);
    avformat_close_input(&format);
    return passed?0:3;
}
