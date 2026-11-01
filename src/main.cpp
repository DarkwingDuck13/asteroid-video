// asteroid-video: a small video player for round AsteroidOS watch screens.
//
// This first version is also a probe: it shows which codecs the watch's Qt
// media backend can decode and how many frames per second actually reach the
// screen, so you can find out what the hardware can really play.
//
// Usage: asteroid-video [file ...]
// With no arguments it plays every video found in ~/videos.

#include <QDir>
#include <QFileInfo>
#include <QGuiApplication>
#include <QMediaFormat>
#include <QQmlContext>
#include <QQuickView>
#include <QStringList>
#include <QUrl>

static QString decoderSummary() {
    QMediaFormat fmt;
    QStringList video;
    for (auto c : fmt.supportedVideoCodecs(QMediaFormat::Decode))
        video << QMediaFormat::videoCodecName(c);
    QStringList audio;
    for (auto c : fmt.supportedAudioCodecs(QMediaFormat::Decode))
        audio << QMediaFormat::audioCodecName(c);
    QStringList files;
    for (auto f : fmt.supportedFileFormats(QMediaFormat::Decode))
        files << QMediaFormat::fileFormatName(f);
    return QString("video: %1\naudio: %2\nfiles: %3")
        .arg(video.join(", "), audio.join(", "), files.join(", "));
}

int main(int argc, char *argv[]) {
    QGuiApplication app(argc, argv);
    app.setApplicationName("asteroid-video");

    QStringList files;
    for (int i = 1; i < argc; ++i) {
        const QString path = QFileInfo(QString::fromLocal8Bit(argv[i])).absoluteFilePath();
        files << QUrl::fromLocalFile(path).toString();
    }

    const QString videoDir = QDir::homePath() + "/videos";
    if (files.isEmpty()) {
        QDir().mkpath(videoDir);
        QDir dir(videoDir);
        const QStringList names = dir.entryList(
            QStringList() << "*.mp4" << "*.m4v" << "*.mkv" << "*.webm" << "*.avi" << "*.mov",
            QDir::Files, QDir::Name);
        for (const QString &n : names)
            files << QUrl::fromLocalFile(dir.absoluteFilePath(n)).toString();
    }

    QQuickView view;
    view.setColor(QColor("#000000"));
    view.rootContext()->setContextProperty("videoFiles", files);
    view.rootContext()->setContextProperty("videoDir", videoDir);
    view.rootContext()->setContextProperty("decoderInfo", decoderSummary());
    view.setSource(QUrl("qrc:/qml/main.qml"));
    view.setResizeMode(QQuickView::SizeRootObjectToView);
    view.showFullScreen();

    return app.exec();
}
