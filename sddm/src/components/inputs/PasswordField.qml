// qmllint disable unqualified

import QtQuick 2.15
import Qt5Compat.GraphicalEffects
import SddmComponents 2.0 as SDDM

Rectangle {
    id: secureInputContainer
    implicitHeight: root.font.pointSize * 4.5
    implicitWidth: parent.width / 2
    anchors.horizontalCenter: parent.horizontalCenter
    color: "transparent"

    property alias password: secureInput
    property Item nextDown
    signal accepted(string password)

    SDDM.TextConstants {
        id: authConstants
    }

    Rectangle {
        id: inputWrapper
        anchors.centerIn: parent
        width: parent.width
        height: root.font.pointSize * 3
        radius: 24
        color: Qt.rgba(parseInt(config.PasswordFieldBackgroundColor.slice(1, 3), 16) / 255, parseInt(config.PasswordFieldBackgroundColor.slice(3, 5), 16) / 255, parseInt(config.PasswordFieldBackgroundColor.slice(5, 7), 16) / 255, 0.12)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.15)

        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 2
            radius: 8
            samples: 16
            color: Qt.rgba(0, 0, 0, 0.15)
        }

        TextInput {
            id: secureInput
            anchors.centerIn: parent
            width: parent.width - 16
            height: parent.height
            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter

            font {
                pointSize: root.font.pointSize
                family: root.font.family
                weight: Font.Bold
            }
            color: config.PasswordFieldTextColor
            focus: true
            selectByMouse: true
            renderType: Text.QtRendering

            echoMode: TextInput.Password
            passwordCharacter: "•"
            passwordMaskDelay: undefined

            onAccepted: secureInputContainer.accepted(secureInput.text)
            KeyNavigation.down: secureInputContainer.nextDown

            Rectangle {
                id: placeholder
                anchors.fill: parent
                color: "transparent"
                visible: secureInput.text === ""

                Text {
                    anchors.centerIn: parent
                    text: authConstants.password
                    color: config.PlaceholderTextColor
                    font: secureInput.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }

        Behavior on border.color {
            ColorAnimation {
                duration: config.AnimationDuration || 80
                easing.type: {
                    switch (config.AnimationEasing) {
                    case "OutCubic":
                        return Easing.OutCubic;
                    case "OutBack":
                        return Easing.OutBack;
                    case "OutQuart":
                    default:
                        return Easing.OutQuart;
                    }
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: config.AnimationDuration || 80
                easing.type: {
                    switch (config.AnimationEasing) {
                    case "OutCubic":
                        return Easing.OutCubic;
                    case "OutBack":
                        return Easing.OutBack;
                    case "OutQuart":
                    default:
                        return Easing.OutQuart;
                    }
                }
            }
        }

        states: [
            State {
                name: "inputFocused"
                when: secureInput.activeFocus
                PropertyChanges {
                    inputWrapper.border.color: config.FocusBorderColor || "#8ab4f8"
                    inputWrapper.border.width: 2
                }
                PropertyChanges {
                    secureInput.color: config.PasswordFieldTextColor
                }
            }
        ]
    }
}
