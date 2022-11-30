class PinLogin {
    constructor ({el, maxNumbers = Infinity,pin}) {
        this.el = {
            main: el,
            numPad: el.querySelector(".pin-login__numpad"),
            textDisplay: el.querySelector(".pin-login__text")
        };
        this.maxNumbers = maxNumbers;
        this.value = "";
        this.pin = pin;

        this._generatePad();
    }

    _generatePad() {
        const padLayout = [
            "1", "2", "3",
            "4", "5", "6",
            "7", "8", "9",
            "backspace", "0", "done"
        ];

        padLayout.forEach(key => {
            const insertBreak = key.search(/[369]/) !== -1;
            const keyEl = document.createElement("div");

            keyEl.classList.add("pin-login__key");
            keyEl.classList.toggle("material-icons", isNaN(key));
            keyEl.textContent = key;
            keyEl.addEventListener("click", () => { this._handleKeyPress(key) });
            this.el.numPad.appendChild(keyEl);

            if (insertBreak) {
                this.el.numPad.appendChild(document.createElement("br"));
            }
        });
    }

    _handleKeyPress(key) {
        switch (key) {
            case "backspace":
                this.value = this.value.substring(0, this.value.length - 1);
                break;
            case "done":
                this._attemptLogin();
                break;
            default:
                if (this.value.length < this.maxNumbers && !isNaN(key)) {
                    this.value += key;
                }
                break;
        }

        this._updateValueText();
    }

    _updateValueText() {
        this.el.textDisplay.value = "_".repeat(this.value.length);
        this.el.textDisplay.classList.remove("pin-login__text--error");
    }

    _attemptLogin() {
        if (this.value.length > 0) {
            if(this.value == this.pin){
                let boxes = document.querySelectorAll('.pin-login__key');
                boxes.forEach(box =>{
                    box.remove();
                });
                let brs = document.querySelectorAll("br")
                brs.forEach(box =>{
                    box.remove();
                })
                this.el.textDisplay.value = "";
                let result = true;
                $.post('https://xuTruckRob/xuTruckRobbery:client:handlePassPost',JSON.stringify(result));
            }
            else{
                let boxes = document.querySelectorAll('.pin-login__key');
                boxes.forEach(box =>{
                    box.remove();
                });
                let brs = document.querySelectorAll("br")
                brs.forEach(box =>{
                    box.remove();
                })
                this.el.textDisplay.value = "";
                let result = false;
                $.post('https://xuTruckRob/xuTruckRobbery:client:handlePassPost',JSON.stringify(result))
            }
        }
    }
}

class RouteImgUi{
  constructor({routeArr}){
    const routeTable = document.getElementById("schedule");
    routeArr.forEach(route=>{
      var row = routeTable.insertRow()
      var cell1 = row.insertCell(0);
      var cell2 = row.insertCell(1);
      var cell3 = row.insertCell(2);

      row.classList.add("scheduleClass");
      cell1.classList.add("scheduleClass");
      cell2.classList.add("scheduleClass");
      cell3.classList.add("scheduleClass");

      cell1.innerHTML = "<div class='circle' style='background-color:" + route.start + "'></div>";
      cell2.innerHTML = "<div class='circle' style='background-color:" + route.stop + "; border:3px solid " + route.stopBorder + ";'></div>";
      cell3.innerHTML = route.time;

    })
  }
}


class PinCodeUI{
    constructor({pinArr}){
        const CONTENT_HOLDER = document.getElementById("content-holder");

  const COLORS = ["cf1719", "3fa535", "feed01", "009fe3"];
  let pin1 = pinArr[0];
  let pin2 = pinArr[1];
  let pin3 = pinArr[2];
  let pin4 = pinArr[3];
  
  let pin1Arr = Array.from(String(pin1), Number);
  let pin2Arr = Array.from(String(pin2), Number);
  let pin3Arr = Array.from(String(pin3), Number);
  let pin4Arr = Array.from(String(pin4), Number);
  let red = 0;
  let green = 0;
  let blue = 0;
  let yellow = 0;

  for (let i = 0; i < 4; i++) {
    for (let j = 0; j < 6; j++) {
      let randomColor = COLORS[Math.floor(Math.random() * COLORS.length)];
      let squareNumber
      let continueOrNot = true;

      while (continueOrNot == true) {
        switch (randomColor) {
          case "cf1719":
            if (red == 6) {
              randomColor = COLORS[Math.floor(Math.random() * COLORS.length)];
            } else {
              squareNumber = pin1Arr[red]
              red = red + 1;
              continueOrNot = false;
            }
            break;
          case "3fa535":
            if (green == 6) {
              randomColor = COLORS[Math.floor(Math.random() * COLORS.length)];
            } else {
              squareNumber = pin2Arr[green]
              green = green + 1;
              continueOrNot = false;
            }
            break;
          case "feed01":
            if (yellow == 6) {
              randomColor = COLORS[Math.floor(Math.random() * COLORS.length)];
            } else {
              squareNumber = pin3Arr[yellow]
              yellow = yellow + 1;
              continueOrNot = false;
            }
            break;
          case "009fe3":
            if (blue == 6) {
              randomColor = COLORS[Math.floor(Math.random() * COLORS.length)];
            } else {
              squareNumber = pin4Arr[blue]
              blue = blue + 1;
              continueOrNot = false;
            }
            break;
        }
      }

      // Hvis baggrundsfarven er gul, så brug sort tekst, ellers så hvid.
      let TextColor = randomColor == "feed01" ? "black" : "white";
      CONTENT_HOLDER.innerHTML +=
        "<input class='form-control square-input' disabled type='tel' value='" +
        squareNumber +
        "' maxlength='1' style='background-color:#" +
        randomColor +
        ";color:" +
        TextColor +
        "'>";
    }

    CONTENT_HOLDER.innerHTML += "<br>";
  }
    }
}

var UI = {
  onDisplayCode: function(){
    addZoom("routeImg")
    window.addEventListener('message', (event) => {
			let item = event.data;
        if(item.codeOrPad == 1){
          if(item.display) {
            mainPinLogin.style.display = "inline-block";
            mainPinLogin.style.background = item.PadBackgroundColor;
            new PinLogin({
              el: document.getElementById("mainPinLogin"),
              maxNumbers: 8,
              pin: item.pin
            });}
			    else {
            mainPinLogin.style.display = "none";
			        }
        }else if(item.codeOrPad == 2) {
          if(item.display){
            PinCodeSquares.style.display = "inline-block";
            new PinCodeUI({
            pinArr: item.pinArr,
            })}
          else {
            PinCodeSquares.style.display = "none";
            }
          } else if(item.codeOrPad == 3) {
            if(item.display){
              routeImgWrapper.style.display = "inline-block";
              new RouteImgUi({
                routeArr: item.routeArr,
                gameTime: item.gameTimeMili,
              })}
            else {
              routeImgWrapper.style.display = "none";
              }
          }else {
                mainPinLogin.style.display = "none";
                PinCodeSquares.style.display = "none";
                routeImgWrapper.style.display = "none";
            }
			
		});

    },
};

document.onkeyup = function (data) 
{
	if (data.which == 27) {
        let boxes = document.querySelectorAll('.pin-login__key');
        boxes.forEach(box =>{
            box.remove();
        });
        let brs = document.querySelectorAll("br");
        brs.forEach(box =>{
            box.remove();
        })
        let inputs = document.querySelectorAll('.square-input');
        inputs.forEach(inp =>{
            inp.remove();
        })
        let schedules = document.querySelectorAll('.scheduleClass');
        schedules.forEach(scT =>{
          scT.remove();
        })

		$.post(`https://xuTruckRob/xuTruckRobbery:client:closeKeyPad`);
	}
};

var addZoom = (target) => {
    // (A) GET CONTAINER + IMAGE SOURCE
    let container = document.getElementById(target),
        imgsrc = container.currentStyle || window.getComputedStyle(container, false);
        imgsrc = imgsrc.backgroundImage.slice(4, -1).replace(/"/g, "");
   
    // (B) LOAD IMAGE + ATTACH ZOOM
    let img = new Image();
    img.src = imgsrc;
    img.onload = () => {
      // (B1) CALCULATE ZOOM RATIO
      let ratio = img.naturalHeight / img.naturalWidth,
          percentage = ratio * 100 + "%";
   
      // (B2) ATTACH ZOOM ON MOUSE MOVE
      container.onmousemove = (e) => {
        let rect = e.target.getBoundingClientRect(),
            xPos = e.clientX - rect.left,
            yPos = e.clientY - rect.top,
            xPercent = xPos / (container.clientWidth / 100) + "%",
            yPercent = yPos / ((container.clientWidth * ratio) / 100) + "%";
   
        Object.assign(container.style, {
          backgroundPosition: xPercent + " " + yPercent,
          backgroundSize: img.naturalWidth + "px"
        });
      };
   
      // (B3) RESET ZOOM ON MOUSE LEAVE
      container.onmouseleave = (e) => {
        Object.assign(container.style, {
          backgroundPosition: "center",
          backgroundSize: "cover"
        });
      };
    }
  };

window.onload = UI.onDisplayCode;