// SPDX-License-Identifier: MIT
// Exercise Qt Quick's OpenGL RHI on the private Wayland session.
#include <QGuiApplication>
#include <QFile>
#include <QImage>
#include <QJsonDocument>
#include <QJsonObject>
#include <QMutex>
#include <QMutexLocker>
#include <QOpenGLContext>
#include <QOpenGLFunctions>
#include <QQuickItem>
#include <QQuickWindow>
#include <QSGSimpleRectNode>
#include <QSurfaceFormat>
#include <QTimer>
#include <atomic>
#include <cstdio>
#include <link.h>

constexpr int Width = 256;
constexpr int Height = 192;
constexpr int Frames = 12;

class ColorGrid final : public QQuickItem
{
public:
    explicit ColorGrid(QQuickItem *parent) : QQuickItem(parent)
    {
        setFlag(ItemHasContents);
        setSize(QSizeF(Width, Height));
    }

    void setFrame(int frame)
    {
        m_frame = frame;
        update();
    }

    static QColor color(int x, int y, int frame)
    {
        const QColor colors[] = {Qt::red, Qt::green, Qt::blue, Qt::white};
        return colors[(x / 16 + 3 * (y / 16) + frame) % 4];
    }

protected:
    QSGNode *updatePaintNode(QSGNode *old, UpdatePaintNodeData *) override
    {
        delete old;
        auto *root = new QSGNode;
        for (int y = 0; y < Height; y += 16)
            for (int x = 0; x < Width; x += 16)
                root->appendChildNode(new QSGSimpleRectNode(
                    QRectF(x, y, 16, 16), color(x, y, m_frame)));
        return root;
    }

private:
    int m_frame = 0;
};

static int graphicsLibrary(dl_phdr_info *info, size_t, void *)
{
    const QString name = QString::fromLocal8Bit(info->dlpi_name);
    if (name.contains("libEGL_") || name.endsWith("mtgpu_dri.so") || name.endsWith("musa_dri.so"))
        std::printf("Graphics library: %s\n", info->dlpi_name);
    return 0;
}

int main(int argc, char **argv)
{
    std::setvbuf(stdout, nullptr, _IOLBF, 0);
    if (argc != 3 || (QByteArray(argv[1]) != "s30" && QByteArray(argv[1]) != "software")) {
        std::fprintf(stderr, "Usage: qt-check s30|software OUTPUT.rgba\n");
        return 2;
    }
    const bool software = QByteArray(argv[1]) == "software";
    const QString output = QString::fromLocal8Bit(argv[2]);
    QSurfaceFormat format;
    format.setRenderableType(QSurfaceFormat::OpenGLES);
    format.setVersion(3, 0);
    format.setSwapInterval(1);
    QSurfaceFormat::setDefaultFormat(format);
    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);
    QString renderer, vendor, version, error;
    bool gles = false;
    QMutex identityMutex;
    std::atomic<unsigned> swaps{0};
    int checked = 0;
    {
        QGuiApplication app(argc, argv);
        if (!QGuiApplication::platformName().startsWith("wayland")) {
            std::fprintf(stderr, "Qt did not use the Wayland platform\n");
            return 2;
        }
        app.setQuitOnLastWindowClosed(false);
        QQuickWindow window;
        window.setTitle("MTT S30 - Qt Quick pixel validation");
        window.setMinimumSize(QSize(Width, Height));
        window.setMaximumSize(QSize(Width, Height));
        window.resize(Width, Height);
        auto *grid = new ColorGrid(window.contentItem());
        QObject::connect(&window, &QQuickWindow::beforeRendering, &window, [&] {
            QMutexLocker lock(&identityMutex);
            if (!renderer.isEmpty()) return;
            auto *context = QOpenGLContext::currentContext();
            if (!context) return;
            auto *gl = context->functions();
            renderer = QString::fromLatin1(reinterpret_cast<const char *>(gl->glGetString(GL_RENDERER)));
            vendor = QString::fromLatin1(reinterpret_cast<const char *>(gl->glGetString(GL_VENDOR)));
            version = QString::fromLatin1(reinterpret_cast<const char *>(gl->glGetString(GL_VERSION)));
            gles = context->isOpenGLES();
        }, Qt::DirectConnection);
        QObject::connect(&window, &QQuickWindow::frameSwapped, &window,
                         [&] { ++swaps; }, Qt::DirectConnection);
        QTimer timer;
        QObject::connect(&timer, &QTimer::timeout, &app, [&] {
            if (!window.isExposed()) return;
            const QImage image = window.grabWindow().convertToFormat(QImage::Format_RGBA8888);
            {
                QMutexLocker lock(&identityMutex);
                const bool cpu = renderer.contains("llvmpipe") || renderer.contains("softpipe");
                if (!gles || renderer.isEmpty() || vendor.isEmpty() ||
                    (software ? !cpu : cpu || !renderer.contains("S30")))
                    error = "Unexpected Qt Quick GLES renderer: " + renderer;
            }
            if (image.size() != QSize(Width, Height))
                error = "Unexpected Qt Quick readback dimensions";
            if (error.isEmpty()) {
                for (int y = 0; y < Height && error.isEmpty(); ++y)
                    for (int x = 0; x < Width; ++x)
                        if (image.pixelColor(x, y) != ColorGrid::color(x, y, checked)) {
                            error = QString("Qt Quick pixel mismatch frame=%1 x=%2 y=%3")
                                        .arg(checked).arg(x).arg(y);
                            break;
                        }
            }
            if (!error.isEmpty()) {
                app.exit(2);
                return;
            }
            if (++checked == Frames) {
                QFile raw(output);
                if (!raw.open(QIODevice::WriteOnly) || image.bytesPerLine() != Width * 4 ||
                    raw.write(reinterpret_cast<const char *>(image.constBits()), Width * Height * 4) != Width * Height * 4 ||
                    !raw.flush() || !image.save(output + ".png", "PNG"))
                    error = "Cannot save Qt Quick readback";
                timer.stop();
                app.exit(error.isEmpty() ? 0 : 2);
            } else {
                grid->setFrame(checked);
            }
        });
        QTimer::singleShot(10000, &app, [&] {
            error = "Qt Quick validation timed out";
            app.exit(2);
        });
        window.show();
        timer.start(80);
        app.exec();
        dl_iterate_phdr(graphicsLibrary, nullptr);
        window.hide();
    }
    // Window, platform integration and application teardown must finish before
    // the final JSON, including Wayland debug output produced by destructors.
    if (checked != Frames || swaps < Frames || !error.isEmpty()) {
        std::fprintf(stderr, "%s checked=%d swaps=%u\n", qPrintable(error), checked, swaps.load());
        return 2;
    }
    QJsonObject result{{"passed", true}, {"mode", software ? "qt-wayland-software" : "qt-wayland-s30"},
                       {"frames", Frames}, {"pixels_checked", Frames * Width * Height},
                       {"mismatches", 0}, {"swapped", int(swaps.load())},
                       {"renderer", renderer}, {"vendor", vendor}, {"gl_version", version},
                       {"opengles", gles}, {"graphics_api", "OpenGL"}, {"window_destroyed", true}};
    std::puts(QJsonDocument(result).toJson(QJsonDocument::Compact).constData());
    return 0;
}
