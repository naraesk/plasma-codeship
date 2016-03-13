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

import QtQuick 2.5
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

Item {
    property alias cfg_title: title.text
    property alias cfg_project: project.text
    property var cfg_branches: []

    id: root
    width: parent.width
    height: parent.height

    Component.onCompleted: {
        var list = plasmoid.configuration.branches
        cfg_branches = []
        for(var i in list) {
            addBranch( JSON.parse(list[i]) )
        }
   }

    function addBranch(object) {
        branchModel.append( object )
        cfg_branches.push( JSON.stringify(object) )
    }

    function removeBranch(index) {
        if(branchModel.count > 0) {
            branchModel.remove(index)
            cfg_branches.splice(index,1)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        Layout.fillWidth: true
        GridLayout {
            id: layout
            columns: 3
            rows: 3
            Layout.fillWidth: true
            width: parent.width
            Label {
                text: i18n('Title')
                Layout.alignment: Qt.AlignRight
            }
        
            TextField {
                id: title
                Layout.fillWidth: true
                Layout.columnSpan: 2
                placeholderText: qsTr("Enter Title")
            }
        
            Label {
                text: i18n('Project UUID')
                Layout.alignment: Qt.AlignRight;
            }
        
            TextField {
                id: project
                Layout.fillWidth: true
                Layout.columnSpan: 2
                placeholderText: qsTr("Enter project UUID")
            }

            Label {
                text: i18n('Branch name')
                Layout.alignment: Qt.AlignRight
            }

            TextField {
                id: name
                Layout.fillWidth: true
                placeholderText: "branch name"
            }

            Button {
                iconName: "list-add"
                onClicked: {
                    var object = ({'branch': name.text})
                    addBranch(object)
                    name.text = ""
                }
            }
       }

        ColumnLayout {
            width: parent.width
            height: parent.height

            ListModel {
                id: branchModel
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    frameVisible: true

                    ListView {
                        width: parent.width
                        model: branchModel

                        delegate: RowLayout {
                            width: parent.width

                            Label {
                                Layout.fillWidth: true
                                text: model.branch
                            }

                            Button {
                                id: removeBranchButton
                                iconName: "list-remove"
                                onClicked: removeBranch(model.index)
                            }
                        }
                    }
                }
            }
        }
    }
} 
