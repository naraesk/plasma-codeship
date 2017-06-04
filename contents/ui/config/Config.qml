/*
 * Copyright (C) 2016-2017 by David Baum <david.baum@naraesk.eu>
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
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2

Item {
    property var cfg_branches: []
    property var cfg_projects: []
    property alias cfg_changed: projectModel.count
    property alias cfg_changed2: theModel.count

    Component.onCompleted: {
        var list = plasmoid.configuration.branches
        cfg_branches = []
        for (var i in list) {
            addBranch(JSON.parse(list[i]))
        }

        list = plasmoid.configuration.projects
        cfg_projects = []
        for (i in list) {
            addProject2(JSON.parse(list[i]))
        }
    }

    function addProject2(project) {
        projectModel.append(project)
        cfg_projects.push(JSON.stringify(project))
    }

    function addProject(title, id) {
        var project = ({
                           id: id,
                           text: title
                       })
        projectModel.append(project)
        selectProject.currentIndex = projectModel.count - 1
        cfg_projects.push(JSON.stringify(project))
    }

    function addBranch(object) {
        theModel.append(object)
        cfg_branches.push(JSON.stringify(object))
    }

    function removeBranch(index) {
        if (theModel.count > 0) {
            theModel.remove(index)
            cfg_branches.splice(index, 1)
        }
    }

    function removeProject(index) {
        var project = projectModel.get(index)
        if (projectModel.count > 0) {
            for (var i = 0; i < theModel.count; i++) {
                var branch = theModel.get(i)
                if(branch.project === project.text) {
                    console.log("yeah, going to delete " + branch.branch + "from " + project.text)
                    theModel.remove(i)
                    cfg_branches.splice(i, 1)
                }
            }
            projectModel.remove(index)
            cfg_projects.splice(index, 1)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        GroupBox {
            Layout.fillWidth: true
            GridLayout {
                columns: 2
                rows: 3
                width: parent.width
                Label {
                    text: qsTr('Title')
                    Layout.alignment: Qt.AlignRight
                }

                TextField {
                    id: projectTitle
                    Layout.fillWidth: true
                    placeholderText: qsTr("Enter title")
                }

                Label {
                    id: label
                    text: i18n('Project UUID')
                    Layout.alignment: Qt.AlignRight
                }

                TextField {
                    id: projectID
                    Layout.fillWidth: true
                    placeholderText: qsTr("Enter project UUID")
                }

                Button {
                    text: qsTr("Add Project")
                    iconName: "list-add"
                    Layout.columnSpan: 2
                    Layout.alignment: Qt.AlignRight
                    onClicked: {
                        addProject(projectTitle.text, projectID.text)
                        projectTitle.text = ""
                        projectID.text = ""
                    }
                }
            }
        }

        GroupBox {
            Layout.fillWidth: true
            GridLayout {
                width: parent.width
                columns: 2
                rows: 3

                Label {
                    text: qsTr('Project')
                    Layout.alignment: Qt.AlignRight
                }

                ComboBox {
                    id: selectProject
                    model: projectModel
                    textRole: "text"
                    onModelChanged: {
                        selectProject.update()
                    }
                }

                Label {
                    text: qsTr('Branch name')
                    Layout.alignment: Qt.AlignRight
                }

                TextField {
                    id: name
                    Layout.fillWidth: true
                    placeholderText: qsTr("Enter branch name")
                }

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    Layout.columnSpan: 2

                    Button {
                        text: qsTr("Add Branch")
                        iconName: "list-add"
                        onClicked: {

                            var object = ({
                                              branch: name.text,
                                              project: selectProject.currentText
                                          })
                            addBranch(object)
                            name.text = ""
                        }
                    }

                    Button {
                        text: qsTr("Remove Project")
                        iconName: "list-remove"

                        Layout.alignment: Qt.AlignRight
                        onClicked: {
                            removeProject(selectProject.currentIndex)
                        }
                    }
                }
            }
        }
        ListModel {
            id: theModel
        }

        ListModel {
            id: projectModel
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Component {
                id: sectionHeading
                Text {
                    text: qsTr("Project: ") + section
                    font.bold: true
                    font.pixelSize: 20
                    color: label.color
                }
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                frameVisible: true

                ListView {
                    model: theModel
                    id: listView

                    section.property: "project"
                    section.criteria: ViewSection.FullString
                    section.delegate: sectionHeading

                    delegate: GridLayout {
                        columns: 2
                        width: parent.width

                        Label {
                            Layout.fillWidth: true
                            text: model.branch
                        }

                        Button {
                            id: removeBranchButtono
                            iconName: "list-remove"
                            onClicked: {
                                removeBranch(model.index)
                            }
                        }
                    }
                }
            }
        }
    }
}
