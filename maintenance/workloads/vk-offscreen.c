/* SPDX-License-Identifier: MIT
 * Small Vulkan 1.0 graphics workload. No window, display server, or swapchain.
 * The normal mode requires S30. Software mode is only a harness self-check.
 */
#include <vulkan/vulkan.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "shaders.h"

#define WIDTH 128u
#define HEIGHT 96u
#define FRAMES 8u
#define BYTES (WIDTH * HEIGHT * 4u)
#define VK(call) do { VkResult r_ = (call); if (r_ != VK_SUCCESS) { \
    fprintf(stderr, "%s failed: %d\n", #call, r_); exit(2); } } while (0)
#define REQUIRE(c, msg) do { if (!(c)) {fprintf(stderr, "%s\n", msg); exit(2);} } while (0)

static uint32_t memory_type(VkPhysicalDevice physical, uint32_t bits,
                            VkMemoryPropertyFlags flags)
{
    VkPhysicalDeviceMemoryProperties p;
    vkGetPhysicalDeviceMemoryProperties(physical, &p);
    for (uint32_t i = 0; i < p.memoryTypeCount; i++)
        if ((bits & (1u << i)) && (p.memoryTypes[i].propertyFlags & flags) == flags)
            return i;
    fprintf(stderr, "No suitable memory type: flags=0x%x\n", flags);
    exit(2);
}

int main(int argc, char **argv)
{
    int software = argc == 3 && !strcmp(argv[1], "--software-validation");
    REQUIRE(argc == 2 || software, "Usage: vk-offscreen [--software-validation] output.rgba");
    const char *path = argv[argc - 1];
    const char *layer = "VK_LAYER_KHRONOS_validation";
    VkApplicationInfo app = {.sType=VK_STRUCTURE_TYPE_APPLICATION_INFO,
        .pApplicationName="S30 pixel correctness", .apiVersion=VK_API_VERSION_1_0};
    VkInstanceCreateInfo ici = {.sType=VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO,
        .pApplicationInfo=&app, .enabledLayerCount=software ? 1u : 0u,
        .ppEnabledLayerNames=software ? &layer : NULL};
    VkInstance instance;
    VK(vkCreateInstance(&ici, NULL, &instance));
    uint32_t count = 0;
    VK(vkEnumeratePhysicalDevices(instance, &count, NULL));
    REQUIRE(count > 0 && count <= 16, "Unexpected Vulkan device count");
    VkPhysicalDevice devices[16], physical = VK_NULL_HANDLE;
    VK(vkEnumeratePhysicalDevices(instance, &count, devices));
    VkPhysicalDeviceProperties properties = {0};
    for (uint32_t i=0; i<count; i++) {
        VkPhysicalDeviceProperties p;
        vkGetPhysicalDeviceProperties(devices[i], &p);
        if ((software && p.deviceType == VK_PHYSICAL_DEVICE_TYPE_CPU) ||
            (!software && p.vendorID == 0x1ed5 && p.deviceID == 0x0102 &&
             p.deviceType == VK_PHYSICAL_DEVICE_TYPE_DISCRETE_GPU)) {
            REQUIRE(physical == VK_NULL_HANDLE, "Ambiguous matching Vulkan devices");
            physical=devices[i]; properties=p;
        }
    }
    REQUIRE(physical != VK_NULL_HANDLE, "Required device absent; software fallback forbidden in S30 mode");
    printf("Device: %s vendor=%04x device=%04x mode=%s\n", properties.deviceName,
           properties.vendorID, properties.deviceID, software ? "software-validation" : "s30");
    fflush(stdout);
    VkFormatProperties fp;
    vkGetPhysicalDeviceFormatProperties(physical, VK_FORMAT_R8G8B8A8_UNORM, &fp);
    REQUIRE(fp.optimalTilingFeatures & VK_FORMAT_FEATURE_COLOR_ATTACHMENT_BIT,
            "RGBA8 color attachment unsupported");
    uint32_t families=0, family=UINT32_MAX;
    vkGetPhysicalDeviceQueueFamilyProperties(physical, &families, NULL);
    REQUIRE(families > 0 && families <= 64, "Unexpected queue family count");
    VkQueueFamilyProperties queues[64];
    vkGetPhysicalDeviceQueueFamilyProperties(physical, &families, queues);
    for (uint32_t i=0; i<families; i++)
        if (queues[i].queueCount && (queues[i].queueFlags & VK_QUEUE_GRAPHICS_BIT)) {family=i;break;}
    REQUIRE(family != UINT32_MAX, "No graphics queue");
    float priority=1;
    VkDeviceQueueCreateInfo qci={.sType=VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO,
        .queueFamilyIndex=family,.queueCount=1,.pQueuePriorities=&priority};
    VkDeviceCreateInfo dci={.sType=VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO,
        .queueCreateInfoCount=1,.pQueueCreateInfos=&qci};
    VkDevice device;
    VK(vkCreateDevice(physical,&dci,NULL,&device));
    VkQueue queue;
    vkGetDeviceQueue(device,family,0,&queue);

    VkImageCreateInfo image_info={.sType=VK_STRUCTURE_TYPE_IMAGE_CREATE_INFO,
        .imageType=VK_IMAGE_TYPE_2D,.format=VK_FORMAT_R8G8B8A8_UNORM,
        .extent={WIDTH,HEIGHT,1},.mipLevels=1,.arrayLayers=1,
        .samples=VK_SAMPLE_COUNT_1_BIT,.tiling=VK_IMAGE_TILING_OPTIMAL,
        .usage=VK_IMAGE_USAGE_COLOR_ATTACHMENT_BIT|VK_IMAGE_USAGE_TRANSFER_SRC_BIT,
        .sharingMode=VK_SHARING_MODE_EXCLUSIVE,.initialLayout=VK_IMAGE_LAYOUT_UNDEFINED};
    VkImage image;
    VK(vkCreateImage(device,&image_info,NULL,&image));
    VkMemoryRequirements requirements;
    vkGetImageMemoryRequirements(device,image,&requirements);
    VkMemoryAllocateInfo ai={.sType=VK_STRUCTURE_TYPE_MEMORY_ALLOCATE_INFO,
        .allocationSize=requirements.size,
        .memoryTypeIndex=memory_type(physical,requirements.memoryTypeBits,VK_MEMORY_PROPERTY_DEVICE_LOCAL_BIT)};
    VkDeviceMemory image_memory;
    VK(vkAllocateMemory(device,&ai,NULL,&image_memory));
    VK(vkBindImageMemory(device,image,image_memory,0));
    VkImageViewCreateInfo vci={.sType=VK_STRUCTURE_TYPE_IMAGE_VIEW_CREATE_INFO,
        .image=image,.viewType=VK_IMAGE_VIEW_TYPE_2D,.format=image_info.format,
        .subresourceRange={VK_IMAGE_ASPECT_COLOR_BIT,0,1,0,1}};
    VkImageView view;
    VK(vkCreateImageView(device,&vci,NULL,&view));
    VkBufferCreateInfo bci={.sType=VK_STRUCTURE_TYPE_BUFFER_CREATE_INFO,
        .size=BYTES,.usage=VK_BUFFER_USAGE_TRANSFER_DST_BIT,.sharingMode=VK_SHARING_MODE_EXCLUSIVE};
    VkBuffer buffer;
    VK(vkCreateBuffer(device,&bci,NULL,&buffer));
    vkGetBufferMemoryRequirements(device,buffer,&requirements);
    ai.allocationSize=requirements.size;
    ai.memoryTypeIndex=memory_type(physical,requirements.memoryTypeBits,
        VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT|VK_MEMORY_PROPERTY_HOST_COHERENT_BIT);
    VkDeviceMemory buffer_memory;
    VK(vkAllocateMemory(device,&ai,NULL,&buffer_memory));
    VK(vkBindBufferMemory(device,buffer,buffer_memory,0));
    uint8_t *pixels;
    VK(vkMapMemory(device,buffer_memory,0,VK_WHOLE_SIZE,0,(void **)&pixels));

    VkAttachmentDescription attachment={.format=image_info.format,.samples=VK_SAMPLE_COUNT_1_BIT,
        .loadOp=VK_ATTACHMENT_LOAD_OP_CLEAR,.storeOp=VK_ATTACHMENT_STORE_OP_STORE,
        .stencilLoadOp=VK_ATTACHMENT_LOAD_OP_DONT_CARE,.stencilStoreOp=VK_ATTACHMENT_STORE_OP_DONT_CARE,
        .initialLayout=VK_IMAGE_LAYOUT_UNDEFINED,.finalLayout=VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL};
    VkAttachmentReference reference={0,VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL};
    VkSubpassDescription subpass={.pipelineBindPoint=VK_PIPELINE_BIND_POINT_GRAPHICS,
        .colorAttachmentCount=1,.pColorAttachments=&reference};
    VkSubpassDependency dependency={.srcSubpass=VK_SUBPASS_EXTERNAL,.dstSubpass=0,
        .srcStageMask=VK_PIPELINE_STAGE_TOP_OF_PIPE_BIT,
        .dstStageMask=VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,
        .dstAccessMask=VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT};
    VkRenderPassCreateInfo rpci={.sType=VK_STRUCTURE_TYPE_RENDER_PASS_CREATE_INFO,
        .attachmentCount=1,.pAttachments=&attachment,.subpassCount=1,.pSubpasses=&subpass,
        .dependencyCount=1,.pDependencies=&dependency};
    VkRenderPass pass;
    VK(vkCreateRenderPass(device,&rpci,NULL,&pass));
    VkFramebufferCreateInfo fbci={.sType=VK_STRUCTURE_TYPE_FRAMEBUFFER_CREATE_INFO,
        .renderPass=pass,.attachmentCount=1,.pAttachments=&view,.width=WIDTH,.height=HEIGHT,.layers=1};
    VkFramebuffer framebuffer;
    VK(vkCreateFramebuffer(device,&fbci,NULL,&framebuffer));
    VkShaderModuleCreateInfo smci={.sType=VK_STRUCTURE_TYPE_SHADER_MODULE_CREATE_INFO,
        .codeSize=sizeof(vertex_spv),.pCode=vertex_spv};
    VkShaderModule vert,frag;
    VK(vkCreateShaderModule(device,&smci,NULL,&vert));
    smci.codeSize=sizeof(fragment_spv);smci.pCode=fragment_spv;
    VK(vkCreateShaderModule(device,&smci,NULL,&frag));
    VkPipelineShaderStageCreateInfo stages[2]={
        {.sType=VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO,.stage=VK_SHADER_STAGE_VERTEX_BIT,.module=vert,.pName="main"},
        {.sType=VK_STRUCTURE_TYPE_PIPELINE_SHADER_STAGE_CREATE_INFO,.stage=VK_SHADER_STAGE_FRAGMENT_BIT,.module=frag,.pName="main"}};
    VkPushConstantRange push={VK_SHADER_STAGE_FRAGMENT_BIT,0,sizeof(uint32_t)};
    VkPipelineLayoutCreateInfo plci={.sType=VK_STRUCTURE_TYPE_PIPELINE_LAYOUT_CREATE_INFO,
        .pushConstantRangeCount=1,.pPushConstantRanges=&push};
    VkPipelineLayout layout;
    VK(vkCreatePipelineLayout(device,&plci,NULL,&layout));
    VkPipelineVertexInputStateCreateInfo vi={.sType=VK_STRUCTURE_TYPE_PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO};
    VkPipelineInputAssemblyStateCreateInfo ia={.sType=VK_STRUCTURE_TYPE_PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO,
        .topology=VK_PRIMITIVE_TOPOLOGY_TRIANGLE_LIST};
    VkViewport viewport={0,0,WIDTH,HEIGHT,0,1};VkRect2D scissor={{0,0},{WIDTH,HEIGHT}};
    VkPipelineViewportStateCreateInfo vs={.sType=VK_STRUCTURE_TYPE_PIPELINE_VIEWPORT_STATE_CREATE_INFO,
        .viewportCount=1,.pViewports=&viewport,.scissorCount=1,.pScissors=&scissor};
    VkPipelineRasterizationStateCreateInfo rs={.sType=VK_STRUCTURE_TYPE_PIPELINE_RASTERIZATION_STATE_CREATE_INFO,
        .polygonMode=VK_POLYGON_MODE_FILL,.cullMode=VK_CULL_MODE_NONE,.frontFace=VK_FRONT_FACE_COUNTER_CLOCKWISE,.lineWidth=1};
    VkPipelineMultisampleStateCreateInfo ms={.sType=VK_STRUCTURE_TYPE_PIPELINE_MULTISAMPLE_STATE_CREATE_INFO,
        .rasterizationSamples=VK_SAMPLE_COUNT_1_BIT};
    VkPipelineColorBlendAttachmentState blend={.colorWriteMask=15};
    VkPipelineColorBlendStateCreateInfo cb={.sType=VK_STRUCTURE_TYPE_PIPELINE_COLOR_BLEND_STATE_CREATE_INFO,
        .attachmentCount=1,.pAttachments=&blend};
    VkGraphicsPipelineCreateInfo pci={.sType=VK_STRUCTURE_TYPE_GRAPHICS_PIPELINE_CREATE_INFO,
        .stageCount=2,.pStages=stages,.pVertexInputState=&vi,.pInputAssemblyState=&ia,.pViewportState=&vs,
        .pRasterizationState=&rs,.pMultisampleState=&ms,.pColorBlendState=&cb,.layout=layout,.renderPass=pass};
    VkPipeline pipeline;
    VK(vkCreateGraphicsPipelines(device,VK_NULL_HANDLE,1,&pci,NULL,&pipeline));
    VkCommandPoolCreateInfo cpci={.sType=VK_STRUCTURE_TYPE_COMMAND_POOL_CREATE_INFO,
        .flags=VK_COMMAND_POOL_CREATE_RESET_COMMAND_BUFFER_BIT,.queueFamilyIndex=family};
    VkCommandPool pool;
    VK(vkCreateCommandPool(device,&cpci,NULL,&pool));
    VkCommandBufferAllocateInfo cai={.sType=VK_STRUCTURE_TYPE_COMMAND_BUFFER_ALLOCATE_INFO,
        .commandPool=pool,.level=VK_COMMAND_BUFFER_LEVEL_PRIMARY,.commandBufferCount=1};
    VkCommandBuffer cmd;
    VK(vkAllocateCommandBuffers(device,&cai,&cmd));
    VkFenceCreateInfo fci={.sType=VK_STRUCTURE_TYPE_FENCE_CREATE_INFO};VkFence fence;
    VK(vkCreateFence(device,&fci,NULL,&fence));
    const uint8_t colors[4][4]={{255,0,0,255},{0,255,0,255},{0,0,255,255},{255,255,255,255}};
    for (uint32_t frame=0;frame<FRAMES;frame++) {
        memset(pixels,0xa5,BYTES);
        VK(vkResetCommandBuffer(cmd,0));
        VkCommandBufferBeginInfo begin={.sType=VK_STRUCTURE_TYPE_COMMAND_BUFFER_BEGIN_INFO};
        VK(vkBeginCommandBuffer(cmd,&begin));
        VkClearValue clear={.color={{0,0,0,0}}};
        VkRenderPassBeginInfo rpbi={.sType=VK_STRUCTURE_TYPE_RENDER_PASS_BEGIN_INFO,
            .renderPass=pass,.framebuffer=framebuffer,.renderArea=scissor,.clearValueCount=1,.pClearValues=&clear};
        vkCmdBeginRenderPass(cmd,&rpbi,VK_SUBPASS_CONTENTS_INLINE);
        vkCmdBindPipeline(cmd,VK_PIPELINE_BIND_POINT_GRAPHICS,pipeline);
        vkCmdPushConstants(cmd,layout,VK_SHADER_STAGE_FRAGMENT_BIT,0,sizeof(frame),&frame);
        vkCmdDraw(cmd,3,1,0,0);
        vkCmdEndRenderPass(cmd);
        VkImageMemoryBarrier ib={.sType=VK_STRUCTURE_TYPE_IMAGE_MEMORY_BARRIER,
            .srcAccessMask=VK_ACCESS_COLOR_ATTACHMENT_WRITE_BIT,.dstAccessMask=VK_ACCESS_TRANSFER_READ_BIT,
            .oldLayout=VK_IMAGE_LAYOUT_COLOR_ATTACHMENT_OPTIMAL,.newLayout=VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,
            .srcQueueFamilyIndex=VK_QUEUE_FAMILY_IGNORED,.dstQueueFamilyIndex=VK_QUEUE_FAMILY_IGNORED,
            .image=image,.subresourceRange={VK_IMAGE_ASPECT_COLOR_BIT,0,1,0,1}};
        vkCmdPipelineBarrier(cmd,VK_PIPELINE_STAGE_COLOR_ATTACHMENT_OUTPUT_BIT,VK_PIPELINE_STAGE_TRANSFER_BIT,
            0,0,NULL,0,NULL,1,&ib);
        VkBufferImageCopy copy={.imageSubresource={VK_IMAGE_ASPECT_COLOR_BIT,0,0,1},.imageExtent={WIDTH,HEIGHT,1}};
        vkCmdCopyImageToBuffer(cmd,image,VK_IMAGE_LAYOUT_TRANSFER_SRC_OPTIMAL,buffer,1,&copy);
        VkBufferMemoryBarrier bb={.sType=VK_STRUCTURE_TYPE_BUFFER_MEMORY_BARRIER,
            .srcAccessMask=VK_ACCESS_TRANSFER_WRITE_BIT,.dstAccessMask=VK_ACCESS_HOST_READ_BIT,
            .srcQueueFamilyIndex=VK_QUEUE_FAMILY_IGNORED,.dstQueueFamilyIndex=VK_QUEUE_FAMILY_IGNORED,
            .buffer=buffer,.offset=0,.size=VK_WHOLE_SIZE};
        vkCmdPipelineBarrier(cmd,VK_PIPELINE_STAGE_TRANSFER_BIT,VK_PIPELINE_STAGE_HOST_BIT,0,0,NULL,1,&bb,0,NULL);
        VK(vkEndCommandBuffer(cmd));
        VkSubmitInfo submit={.sType=VK_STRUCTURE_TYPE_SUBMIT_INFO,.commandBufferCount=1,.pCommandBuffers=&cmd};
        VK(vkQueueSubmit(queue,1,&submit,fence));
        VK(vkWaitForFences(device,1,&fence,VK_TRUE,UINT64_C(10000000000)));
        for (uint32_t y=0;y<HEIGHT;y++) for (uint32_t x=0;x<WIDTH;x++) {
            uint32_t tile=(x/16+3*(y/16)+frame)%4;
            if (memcmp(pixels+4*(y*WIDTH+x),colors[tile],4)) {
                fprintf(stderr,"Pixel mismatch frame=%u x=%u y=%u: %u,%u,%u,%u\n",frame,x,y,
                    pixels[4*(y*WIDTH+x)],pixels[4*(y*WIDTH+x)+1],pixels[4*(y*WIDTH+x)+2],pixels[4*(y*WIDTH+x)+3]);
                exit(3);
            }
        }
        VK(vkResetFences(device,1,&fence));
        printf("Frame %u: %u pixels matched\n",frame,WIDTH*HEIGHT);fflush(stdout);
    }
    FILE *file=fopen(path,"wb");REQUIRE(file,"Cannot create readback file");
    REQUIRE(fwrite(pixels,1,BYTES,file)==BYTES,"Cannot write readback file");
    REQUIRE(!fclose(file),"Cannot close readback file");
    VK(vkDeviceWaitIdle(device));
    vkDestroyFence(device,fence,NULL);vkDestroyCommandPool(device,pool,NULL);
    vkDestroyPipeline(device,pipeline,NULL);vkDestroyPipelineLayout(device,layout,NULL);
    vkDestroyShaderModule(device,vert,NULL);vkDestroyShaderModule(device,frag,NULL);
    vkDestroyFramebuffer(device,framebuffer,NULL);vkDestroyRenderPass(device,pass,NULL);
    vkUnmapMemory(device,buffer_memory);vkDestroyBuffer(device,buffer,NULL);vkFreeMemory(device,buffer_memory,NULL);
    vkDestroyImageView(device,view,NULL);vkDestroyImage(device,image,NULL);vkFreeMemory(device,image_memory,NULL);
    vkDestroyDevice(device,NULL);vkDestroyInstance(instance,NULL);
    printf("{\"passed\":true,\"mode\":\"%s\",\"frames\":%u,\"pixels_checked\":%u,\"mismatches\":0}\n",
        software?"software-validation":"s30",FRAMES,WIDTH*HEIGHT*FRAMES);
    return 0;
}
