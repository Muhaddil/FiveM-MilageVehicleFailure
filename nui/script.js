(function () {
  const meterElement = document.querySelector(".distance-display");
  const valueElement = document.querySelector(".distance-value");
  const unitElement = document.querySelector(".distance-unit");

  function updatePosition(position) {
    meterElement.style.top = "";
    meterElement.style.bottom = "";
    meterElement.style.left = "";
    meterElement.style.right = "";
    meterElement.style.transform = "";

    const padding = "5%";

    switch (position) {
      case "bottom-right":
        meterElement.style.bottom = padding;
        meterElement.style.right = padding;
        meterElement.style.maxWidth = "calc(100% - 16px)";
        meterElement.style.maxHeight = "calc(100% - 16px)";
        break;
      case "bottom-left":
        meterElement.style.bottom = padding;
        meterElement.style.left = padding;
        meterElement.style.maxWidth = "calc(100% - 16px)";
        meterElement.style.maxHeight = "calc(100% - 16px)";
        break;
      case "top-right":
        meterElement.style.top = padding;
        meterElement.style.right = padding;
        meterElement.style.maxWidth = "calc(100% - 16px)";
        meterElement.style.maxHeight = "calc(100% - 16px)";
        break;
      case "top-left":
        meterElement.style.top = padding;
        meterElement.style.left = padding;
        meterElement.style.maxWidth = "calc(100% - 16px)";
        meterElement.style.maxHeight = "calc(100% - 16px)";
        break;
      case "bottom-center":
        meterElement.style.bottom = padding;
        meterElement.style.left = "50%";
        meterElement.style.transform = "translateX(-50%)";
        meterElement.style.maxWidth = "calc(100% - 16px)";
        meterElement.style.maxHeight = "calc(100% - 16px)";
        break;
      case "top-center":
        meterElement.style.top = padding;
        meterElement.style.left = "50%";
        meterElement.style.transform = "translateX(-50%)";
        meterElement.style.maxWidth = "calc(100% - 16px)";
        meterElement.style.maxHeight = "calc(100% - 16px)";
        break;
      default:
        meterElement.style.bottom = padding;
        meterElement.style.right = padding;
        meterElement.style.maxWidth = "calc(100% - 16px)";
        meterElement.style.maxHeight = "calc(100% - 16px)";
        break;
    }
  }

  window.addEventListener("message", (event) => {
    const data = event.data;

    if (!data) return;

    if (data.type === "show") {
        meterElement.style.display = "flex";
        const newValue = Math.floor(data.value).toString().padStart(6, "0");
        const digits = valueElement.querySelectorAll('.digit');

        digits.forEach((digit, index) => {
            const currentDigitValue = digit.dataset.value;
            const newDigitValue = newValue[index];

            if (currentDigitValue !== newDigitValue) {
                digit.classList.add('scale');
                digit.dataset.value = newDigitValue;
                digit.textContent = newDigitValue;

                setTimeout(() => {
                    digit.classList.remove('scale');
                }, 1000);
            }
        });

        unitElement.innerHTML = data.unit === "miles" ? "MI" : "KM";
        updatePosition(data.position);
    } else if (data.type === "hide") {
        meterElement.style.display = "none";
    }
});

let currentSound;

window.addEventListener("message", (event) => {
    const data = event.data;

    if (!data) return;

    if (data.type === "showWarning") {
        let warningDiv = document.querySelector('.warning-message');

        if (!warningDiv) {
            warningDiv = document.createElement("div");
            warningDiv.className = "warning-message";

            const warningImage = document.createElement("img");
            warningImage.src = "img/brakelight.png";
            warningDiv.appendChild(warningImage);

            document.body.appendChild(warningDiv);
        }

        if (currentSound) {
            currentSound.pause();
            currentSound.currentTime = 0;
        }

        currentSound = new Audio(`https://r2.fivemanage.com/pub/ekxsg730w1eu.mp3`);
        currentSound.volume = 0.20;
        currentSound.play().then(function() {
        }).catch(function(error) {
        });

        warningDiv.style.display = "block";
    } else if (data.type === "hideWarning") {
        const warningDiv = document.querySelector('.warning-message');
        if (warningDiv) {
            warningDiv.remove();
        }
    }
});
})();
