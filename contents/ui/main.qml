/*
 * Copyright (C) 2016 by David Baum <david.baum@naraesk.eu>
 *
 * This file is part of plasma-codeship.
 *
 * plasma-codeship is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * plasma-codeship is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with plasma-codeship.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Controls.Styles 1.2

Item {
    
    property string title: plasmoid.configuration.title
    property string project: plasmoid.configuration.project

    Component.onCompleted: {
        loadBranches();
     }

    Connections {
        target: plasmoid.configuration
        onBranchesChanged: loadBranches()
    }

    function loadBranches() {
        branchModel.clear();
        var list = plasmoid.configuration.branches
        for(var i in list) {
            var item = JSON.parse(list[i])
            branchModel.append( item )
        }
    }

    Label {
        id: heading
        text: title
        anchors.top: parent.top
        anchors.horizontalCenter: grid.horizontalCenter
        font.pointSize : 14
        horizontalAlignment: "AlignHCenter"
    }
    
    ColumnLayout {
        id: grid
        width: parent.width
        height: parent.height
        anchors.top: heading.bottom
        anchors.topMargin: 10
        ListModel {
            id: branchModel
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    Layout.alignment: Qt.AlignLeft
                    width: parent.width
                    model: branchModel

                    delegate: RowLayout {
                        width: parent.width
                        Layout.alignment: Qt.AlignLeft

                        Label {
                            text: model.branch
                            anchors.right: parent.horizontalCenter
                            anchors.rightMargin: 30
                            Layout.alignment: Qt.AlignRight
                            horizontalAlignment: Text.AlignRight
                        }

                        Image {
                            id: img
                            anchors.left: parent.horizontalCenter
                            anchors.leftMargin: -20
                            source: "https://codeship.com/projects/" + project + "/status?branch=" + model.branch
                            cache: false
                            function reload() {
                                source = "";
                                source = "https://codeship.com/projects/" + project + "/status?branch=" + model.branch;
                            }
                        }

                        Timer {
                            interval: 300000; // 5 minutes
                            running: true;
                            repeat: true
                            onTriggered: {
                                img.reload()
                            }
                        }
                    }
                }
            }
        }
    }
}
