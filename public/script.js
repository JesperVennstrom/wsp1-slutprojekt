
function showPopup() {
    document.getElementById('popup').style.display = 'block';
    overlay.style.display = 'block';
}

function hidePopup() {
    document.getElementById('popup').style.display = 'none';
    overlay.style.display = 'none';
}

function depositMoney() {
    const amount = document.getElementById('depositAmount').value;
    if (amount && !isNaN(amount)) {
        alert(`You have deposited $${amount}`);
        hidePopup();
    } else {
        alert('Please enter a valid amount.');
    }
}
function updateSlider(odd, id) {
    odds_percent = parseInt(odd) / 10;
    odd_string = `${odds_percent}%`;
    wild_value = 100;
    for (let i = 1; i <= 6; i++) {
        if (i == id) {
            document.getElementById(`odd${i}`).innerHTML = odds_string;
        }
        wild_value -= parseFloat(document.getElementById(`odd${i}`).innerHTML.trim());
    }
    document.getElementById("wild").innerHTML = `${wild_value}%`; 
    if (wild_value < 0) {
        document.getElementById("odds_submit").style.display = "none";
    } else {
        document.getElementById("odds_submit").style.display = "block";
    }
}

async function randomizer() {
    let  max = 1000;
    const tiles = document.getElementsByClassName("tile");
    const parent = document.getElementsByClassName("slot-machine");

    const winDisplay = document.getElementById("win_amount");

    winDisplay.innerHTML = "";

    await fetch("http://localhost:9292/getodds", {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json'
        }
    })
        .then((response) => {
            if (!response.ok) {
                // error processing
                throw 'Error';
            }
            return response.json()
        })
        .then(data => {
            if (data.success) {
                stats = data.stats;
                console.log(stats);
            } else {
                console.error("Error updating odds:", data.message);
            }
        });
    
    for (const tile of tiles) {
        if (tile.parentElement == parent[0].children[0]) {
            max = stats[5];
        } else if(tile.parentElement == parent[0].children[2]) {
            max = 1050;
        } else {
            max = 1000;
        }
        const x = Math.floor(Math.random() * max);
        if (x < stats[0]) {
            symbol = "CRUSIFIX2.png";
        } else if (x < stats[1]) {
            symbol = "PENTAGRAM.png";
        } else if (x < stats[2]) {
            symbol = "TRIDENT.png";
        } else if (x < stats[3]) {
            symbol = "ZOMBIE_LOGO.png";
        } else if (x < stats[4]) {
            symbol = "GHOST_LOGO2.png";
        } else if (x < stats[5]) {
            symbol = "DEMON_LOGO.png";
        } else if (x < 1000) {
            symbol = "WILD_ICON.png";
        } else {
            symbol = "jonkler.png";
        }

        tile.querySelector('img').src = `img/${symbol}`; 
    }
    
    const slotContainer = document.getElementsByClassName("slot-container");
    const tileHeight = document.querySelector(".tile").offsetHeight + 2; // Get the height of a tile
    const totalTiles = document.querySelectorAll(".tile").length / 5;

        
    let totalScrollDistance = tileHeight * (totalTiles - 4); // Scroll through most tiles

    let delay = 0;
    let spinDuration = (2000); // How long the spin lasts (2s)
    
        // Start scrolling animation
    for (const container of slotContainer) {
        container.style.transition = 'none'; // Disable transition
        container.style.transform = `translateY(0)`; // Reset the position
        setTimeout(() => {
            setTimeout(() => {
                container.style.transition = `transform ${spinDuration / 1000}s ease-out`; // Enable transition
                let random = Math.floor((Math.random() - 0.5) * tileHeight * 2 - 10);
                container.style.transform = `translateY(-${totalScrollDistance + random}px)`; // Scroll to the
            }, 100); // Wait for 100ms before starting the spin
            setTimeout(() => {
                container.style.transition = `transform ${1.2}s ease-out`;
                container.style.transform = `translateY(-${totalScrollDistance}px)`; // Scroll to the selected tile
            }, spinDuration); // Wait for the spin duration before resetting the position
        }, delay); // Wait for 100ms before starting the spin
        delay += 400;

    }
    let win_amount = win();
    setTimeout(async() => {
        try {
            win_amount += await jackpot();
            UpdateBalance(20, win_amount);
        } catch (error){
            console.error("Error in jackpot:", error);
        }
    }, 4700);
}
async function jackpot() {
    const jackpot_container = document.getElementsByClassName("slot-container")[2];
    let jackpot = false;
    for(let i = 0; i < 3; i++) {
        console.log(jackpot_container.children[11+i].querySelector('img').src.endsWith("jonkler.png"));
        if (jackpot_container.children[11+i].querySelector('img').src.endsWith("jonkler.png")) {
            jackpot = true;
        }
    }
    if (jackpot) {
        const weights = await createSlices();
        const arrow = document.getElementById("arrow");
        arrow.style.borderTop = "20px solid white";
        return new Promise((resolve) => {
            setTimeout (() => {
                const wheel = document.getElementById("wheel");
                const slices = wheel.querySelectorAll("path");
                const totalSlices = slices.length;
                console.log("Total slices: " + totalSlices);  
                const spinDuration = 3000; // Spin duration in milliseconds
                const spinAngle = Math.floor(Math.random() * 360) + 720; // Random angle between 720 and 1080 degrees
            
                wheel.style.transition = `transform ${spinDuration}ms ease-out`;
                wheel.style.transform = `rotate(${spinAngle}deg)`;
            
                setTimeout(() => {
                    wheel.style.transition = "none";
                    const finalAngle = spinAngle % 360;
                    wheel.style.transform = `rotate(${finalAngle}deg)`; 

                    const pointerAngle = (360 - finalAngle) % 360;
                    const hit = weights.find(slice =>
                        pointerAngle >= slice.startAngle && pointerAngle < slice.endAngle
                    );
            
                    console.log("🎯 Slice at pointer:", hit?.label);
                    let win_amount = hit?.value;
                    setTimeout(() => {
                        while (wheel.firstChild) {
                            wheel.removeChild(wheel.firstChild);
                        }
                        arrow.style.borderTop = "none";
                        resolve(win_amount);
                    }, 5000);
                }, spinDuration);
            }, 1000);
        });
        
    }else {
        return 0;
    }
}
async function createSlices() {
    const weights = [
        { label: "Grand", color: "red", value:5000 , weight: 20 },
        { label: "Major", color: "green",  value:1000 ,weight: 30 },
        { label: "Minor", color: "blue", value:500 ,weight: 50 }
    ];
    try {
        const response = await fetch("http://localhost:9292/getjackpot", {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        if (!response.ok) throw new Error('Fetch error');

        const data = await response.json();

        if (data.success) {
            const color_list = ["orange", "purple", "yellow", "pink", "cyan", "lime"];
            for (let i = 0; i < data.jackpots.length; i++) {
                const random_int = Math.floor(Math.random() * color_list.length);
                const color = color_list.splice(random_int, 1)[0];

                weights.push({
                    label: data.jackpots[i][0],
                    color: color,
                    value: data.jackpots[i][1],
                    weight: data.jackpots[i][2]
                });
            }
        }
        
        console.log(weights);
        const totalWeight = weights.reduce((sum, item) => sum + item.weight, 0);
        const radius = 150;
        let startAngle = 0;
        const svg = document.getElementById("wheel");

        sliceData = [];
        
        weights.forEach((item) => {
            const angle = (item.weight / totalWeight) * 360;
            const endAngle = startAngle + angle;
            const pathData = describeArc(150, 150, radius, startAngle, endAngle);
        
            const path = document.createElementNS("http://www.w3.org/2000/svg", "path");
            path.setAttribute("d", pathData);
            path.setAttribute("fill", item.color);
            path.setAttribute("stroke", "#fff");
            path.setAttribute("stroke-width", "2");
            path.setAttribute("data-label", item.label);
            svg.appendChild(path);

            const midAngle = startAngle + angle / 2;
            const labelPos = polarToCartesian(150, 150, radius * 0.6, midAngle);
            const text = document.createElementNS("http://www.w3.org/2000/svg", "text"); 
            text.setAttribute("x", labelPos.x);
            text.setAttribute("y", labelPos.y);
            text.setAttribute("text-anchor", "middle");
            text.setAttribute("alignment-baseline", "middle");
            text.setAttribute("fill", "#fff"); // or another contrasting color
            text.setAttribute("font-size", "14");
            text.setAttribute("font-family", "sans-serif");
            text.textContent = item.label;
            svg.appendChild(text);

            sliceData.push({
                label: item.label,
                value: item.value,
                startAngle,
                endAngle
            });
            startAngle = endAngle;
        });
        return sliceData;
    } catch (error) {
        console.error("Something went wrong in createSlices:", error);
        return [];
    }

}
function polarToCartesian(cx, cy, r, angleInDegrees) {
    const rad = (angleInDegrees - 90) * Math.PI / 180;
    return {
      x: cx + r * Math.cos(rad),
      y: cy + r * Math.sin(rad),
    };
  }
  
function describeArc(cx, cy, r, startAngle, endAngle) {
    const start = polarToCartesian(cx, cy, r, endAngle);
    const end = polarToCartesian(cx, cy, r, startAngle);
    const largeArcFlag = endAngle - startAngle > 180 ? 1 : 0;
  
    return [
      `M ${cx} ${cy}`,
      `L ${start.x} ${start.y}`,
      `A ${r} ${r} 0 ${largeArcFlag} 0 ${end.x} ${end.y}`,
      `Z`,
    ].join(" ");
}

function win() {
    const containers = document.getElementsByClassName("slot-container");
    let win = 0;
    let win_array1 = [];
    let win_array2 = [];
    let win_array3 = [];

    for (const container of containers) {   
        win_array1.push(container.children[11]);
        win_array2.push(container.children[12]);
        win_array3.push(container.children[13]);
    }

    let win_arrays = [win_array1, win_array2, win_array3];
    
    for (const win_array of win_arrays) {
        let win_tiles = 0;
        for(let i = 0; i < win_array.length; i++) {   
            if (win_array[i].querySelector('img').src.endsWith("WILD_ICON.png")) {
                win_array[i].innerHTML = win_array[0].innerHTML;
                setTimeout (() => {
                    win_array[i].querySelector('img').src = `img/WILD_ICON.png`;
                }, 10);
            }
        }
            if (win_array[0].innerHTML === win_array[1].innerHTML && win_array[1].innerHTML === win_array[2].innerHTML) {
                win_tiles = 3;
                if (win_array[0].innerHTML === win_array[3].innerHTML) {
                    win_tiles = 4;
                    if (win_array[0].innerHTML === win_array[4].innerHTML) {
                        win_tiles = 5;
                    }
                }
            }
            if (win_tiles > 0) {
                if (win_array[0].querySelector('img').src.endsWith("CRUSIFIX2.png")) {
                    console.log("win");
                    if (win_tiles == 3) {
                        win += 10;
                    } else if (win_tiles == 4) {
                        win += 20;
                    } else if (win_tiles == 5) {
                        win += 50;
                    }
                } else if (win_array[0].querySelector('img').src.endsWith("PENTAGRAM.png")) {
                    console.log("win");
                    if (win_tiles == 3) {
                        win += 20;
                    } else if (win_tiles == 4) {
                        win += 40;
                    } else if (win_tiles == 5) {
                        win += 100;
                    }
                } else if (win_array[0].querySelector('img').src.endsWith("TRIDENT.png")) {
                    console.log("win");
                    if (win_tiles == 3) {
                        win += 30;
                    } else if (win_tiles == 4) {
                        win += 60;
                    } else if (win_tiles == 5) {
                        win += 150;
                    }
                } else if (win_array[0].querySelector('img').src.endsWith("ZOMBIE_LOGO.png")) {
                    console.log("win");
                    if (win_tiles == 3) {
                        win += 40;
                    } else if (win_tiles == 4) {
                        win += 80;
                    } else if (win_tiles == 5) {
                        win += 200;
                    }
                } else if (win_array[0].querySelector('img').src.endsWith("GHOST_LOGO2.png")) {
                    console.log("win");
                    if (win_tiles == 3) {
                        win += 50;
                    } else if (win_tiles == 4) {
                        win += 100;
                    } else if (win_tiles == 5) {
                        win += 250;
                    }
                } else if (win_array[0].querySelector('img').src.endsWith("DEMON_LOGO.png")) {
                    console.log("win");
                    if (win_tiles == 3) {
                        win += 60;
                    } else if (win_tiles == 4) {
                        win += 120;
                    } else if (win_tiles == 5) {
                        win += 300;
                    }
                }
            }
    }
    console.log(win);
    setTimeout (() => {
        document.getElementById("win_amount").innerHTML = `$${win}`;
    }, 4700);
    return win;
}
function UpdateBalance(bet, win_amount) {
    fetch("http://localhost:9292/updatebalance", {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            bet: bet,
            win: win_amount
        })
    })
        .then((response) => {
            if (!response.ok) {
                // error processing
                throw 'Error';
            }
            return response.json()
        })
        .then(data => {
            if (data.success) {
                console.log(data);
                document.getElementById('balance').innerHTML = `Balance: $${data.balance}`;
            } else {
                console.error("Error updating balance:", data.message);
            }
        });

}
