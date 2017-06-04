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
import QtQuick 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Controls.Styles 1.4

Item {
    anchors.margins: 20

    Component.onCompleted: {
        loadProjects()
        loadBranches()
    }

    Connections {
        target: plasmoid.configuration
        onBranchesChanged: loadBranches()
        onProjectsChanged: loadProjects()
    }

    function loadBranches() {
        branchModel.clear()
        var list = plasmoid.configuration.branches
        for (var i in list) {
            var item = JSON.parse(list[i])
            for (var j = 0; j < projectModel.count; j++) {
                var project = projectModel.get(j)
                if (item.project === project.text) {
                    item["id"] = project.id
                    branchModel.append(item)
                }
            }
        }
    }

    function loadProjects() {
        projectModel.clear()
        var list = plasmoid.configuration.projects
        for (var i in list) {
            var item = JSON.parse(list[i])
            projectModel.append(item)
        }
    }

    RowLayout {
        height: parent.height
        width: parent.width

        ListModel {
            id: branchModel
        }
        ListModel {
            id: projectModel
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: projectModel
            id: listView
            spacing: 10

            delegate: GroupBox {
                id: wrapper
                title: model.text
                width: parent.width
                checkable: true
                property int orgHeight

                onCheckedChanged: {
                    if (checked) {
                        col.visible = true
                        wrapper.height = orgHeight
                    } else {
                        col.visible = false
                        orgHeight = height
                        wrapper.height = 40
                    }
                }

                Connections {
                    target: plasmoid.configuration
                    onBranchesChanged:update()
                }

                function update() {
                    theModel.clear()
                    for (var i = 0; i < branchModel.count; i++) {
                        var branch = branchModel.get(i)
                        if (model.text === branch.project) {
                            insidelist.model.append(branch)
                        }
                    }
                }

                Component.onCompleted: {
                   update()
                }

                ListModel {
                    id: theModel
                }
                Column {
                    id: col
                    width: parent.width
                    Repeater {
                        id: insidelist
                        model: theModel

                        anchors.fill: parent
                        delegate: RowLayout {
                            width: parent.width
                            Label {
                                text: model.branch
                                Layout.alignment: Qt.AlignRight
                                horizontalAlignment: Text.AlignRight
                                anchors.right: img.left
                                anchors.rightMargin: 10
                                Layout.fillWidth: true
                            }

                            Image {
                                id: img
                                Layout.alignment: Qt.AlignLeft
                                anchors.left: parent.horizontalCenter
                                anchors.leftMargin: -30
                                source: "https://codeship.com/projects/" + model.id
                                        + "/status?branch=" + model.branch
                                cache: false
                                function reload() {
                                    source = ""
                                    source = "https://codeship.com/projects/" + model.id
                                            + "/status?branch=" + model.branch
                                }
                            }

                            Timer {
                                interval: 300000 // 5 minutes
                                running: true
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
}
