import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
  id: widget

  Plasmoid.onActivated: widget.activate()

  Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation

  Plasmoid.icon: "input-keyboard"

  Plasmoid.compactRepresentation: Item {
      id: mainicon

		PlasmaCore.IconItem {
          id: itemIconImage
          anchors.fill: parent
          //anchors.margins: units.smallSpacing
          source: "input-keyboard"
        }

		MouseArea {
			id: mouseArea
			anchors.fill: parent
			hoverEnabled: true
			onClicked: widget.activate()
		}
	}

    PlasmaCore.DataSource {
		id: executable
		engine: "executable"
		connectedSources: []
		onNewData: {
           var exitCode = data["exit code"]
           var exitStatus = data["exit status"]
           var stdout = data["stdout"]
           var stderr = data["stderr"]
           exited(sourceName, exitCode, exitStatus, stdout, stderr)
           disconnectSource(sourceName)
           //connectedSources.pop()
        }

		function exec(cmd) {
			executable.connectSource(cmd)
		}
		signal exited(string sourceName, int exitCode, int exitStatus, string stdout, string stderr )
	}

    Connections {
        target: executable
        onExited: {
          if ( sourceName == "pgrep onboard" ) {
              //check for stdout = pid
              if ( exitCode == 1 ) {
                //not found
                executable.exec("onboard")
              }
          }
        }
    }

    function activate() {
        executable.exec("pgrep onboard")
		executable.exec('qdbus org.onboard.Onboard /org/onboard/Onboard/Keyboard ToggleVisible')
	}

    
  }