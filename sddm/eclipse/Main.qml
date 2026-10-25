// ###################
// The Eclipse login screen (SDDM, Qt 6): the same look as the lock screen. The wallpaper blurred
// and darkened, the time large with a rose glow, the date, your name, and a password field with a
// rose → plum edge (red and a shake if the password is wrong). Bottom left: the session; bottom
// right: sleep, restart, shut down. Colors from theme.conf (theme/generate.sh)
// ###################
import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: config.bg

    property string session: ""
    property string user: userModel.lastUser
    property bool failed: false

    // --- the wallpaper, blurred and darkened, fading to near-black at the bottom
    Image {
        id: wallpaper
        anchors.fill: parent
        source: "background.png"
        fillMode: Image.PreserveAspectCrop
        visible: false
    }
    MultiEffect {
        anchors.fill: parent
        source: wallpaper
        blurEnabled: true
        blur: 0.3
        blurMax: 32
        brightness: -0.12
    }
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.alpha(config.header, 0.15) }
            GradientStop { position: 0.6; color: Qt.alpha(config.header, 0.35) }
            GradientStop { position: 1.0; color: Qt.alpha(config.header, 0.8) }
        }
    }

    // --- the time, the date, your name, the password
    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -40
        spacing: 14

        Text {
            id: clock
            anchors.horizontalCenter: parent.horizontalCenter
            color: config.ink
            font.family: config.font
            font.pixelSize: 110
            font.weight: Font.Light
            text: Qt.formatTime(new Date(), "HH:mm")
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: config.accent
                shadowBlur: 1.0
                shadowOpacity: 0.8
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 0
            }
        }
        Text {
            id: date
            anchors.horizontalCenter: parent.horizontalCenter
            color: config.muted
            font.family: config.font
            font.pixelSize: 22
            text: Qt.formatDate(new Date(), "dddd, d MMMM")
        }
        Item { width: 1; height: 36 }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: config.ink
            font.family: config.font
            font.pixelSize: 18
            font.weight: Font.Medium
            text: root.user
        }

        // the password field: a rose → plum edge around dark glass
        Rectangle {
            id: field
            anchors.horizontalCenter: parent.horizontalCenter
            width: 340
            height: 52
            radius: 14
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: root.failed ? config.error : config.accent }
                GradientStop { position: 1.0; color: root.failed ? config.error : config.plum }
            }
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: root.failed ? config.error : config.accent
                shadowBlur: 0.8
                shadowOpacity: 0.5
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 0
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 2
                radius: 12
                color: config.surface

                TextField {
                    id: password
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    focus: true
                    echoMode: TextInput.Password
                    passwordCharacter: "●"
                    horizontalAlignment: TextInput.AlignHCenter
                    color: config.ink
                    font.family: config.font
                    font.pixelSize: 16
                    background: null
                    selectionColor: config.select
                    onTextEdited: root.failed = false
                    onAccepted: sddm.login(root.user, text, sessionModel.lastIndex)
                }
                Text {
                    anchors.centerIn: parent
                    visible: password.text.length === 0
                    color: root.failed ? config.error : config.faint
                    font.family: config.font
                    font.pixelSize: 16
                    text: root.failed ? "Wrong password" : "Password"
                }
            }

            SequentialAnimation {
                id: shake
                loops: 2
                NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: -10; duration: 50 }
                NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: 10; duration: 100 }
                NumberAnimation { target: field; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50 }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: config.warn
            font.family: config.font
            font.pixelSize: 14
            text: keyboard.capsLock ? "Caps Lock is on" : " "
        }
    }

    // --- whose login: the last user, or the first one there is
    Repeater {
        model: userModel
        delegate: Item {
            Component.onCompleted: if (root.user === "" && index === 0) root.user = name
        }
    }

    // --- bottom left: the session that starts (the last one used)
    Repeater {
        model: sessionModel
        delegate: Item {
            Component.onCompleted: if (index === sessionModel.lastIndex) root.session = name
        }
    }
    Text {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 28
        color: config.faint
        font.family: config.font
        font.pixelSize: 15
        text: root.session
    }

    // --- bottom right: sleep, restart, shut down
    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 24
        spacing: 22

        Repeater {
            model: [
                { icon: "", label: "Sleep", ok: sddm.canSuspend, act: function() { sddm.suspend() } },
                { icon: "", label: "Restart", ok: sddm.canReboot, act: function() { sddm.reboot() } },
                { icon: "", label: "Shut down", ok: sddm.canPowerOff, act: function() { sddm.powerOff() } }
            ]
            delegate: Text {
                visible: modelData.ok
                color: hover.hovered ? config.accent : config.muted
                font.family: "Symbols Nerd Font Mono"
                font.pixelSize: 24
                text: modelData.icon
                HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: modelData.act() }
                ToolTip.visible: hover.hovered
                ToolTip.text: modelData.label
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            clock.text = Qt.formatTime(new Date(), "HH:mm")
            date.text = Qt.formatDate(new Date(), "dddd, d MMMM")
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.failed = true
            password.text = ""
            shake.start()
        }
    }

    Component.onCompleted: password.forceActiveFocus()
}
