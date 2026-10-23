import QtQuick 2.0;
import QtQuick.Controls 2.0;

Rectangle {
    width: 800;
    height: 500;
    color: "#0F1117";

    Image {
        id: slideImage;
        anchors.fill: parent;
        source: "slide1.png";
        fillMode: Image.PreserveAspectCrop;
        opacity: 0.85;
    }

    Rectangle {
        anchors.bottom: parent.bottom;
        anchors.left: parent.left;
        anchors.right: parent.right;
        height: 120;
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent"; }
            GradientStop { position: 1.0; color: "#0F1117"; }
        }
    }

    Text {
        anchors.bottom: parent.bottom;
        anchors.bottomMargin: 30;
        anchors.horizontalCenter: parent.horizontalCenter;
        text: "Willkommen bei CozyHaze OS — Speziell optimiert für Apple MacBook Pro 2011";
        color: "#00F2FE";
        font.pixelSize: 16;
        font.bold: true;
    }
}
