
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
    if (id == 1) {
        document.getElementById("odd1").innerHTML = odd;
    } else if (id == 2) {
        document.getElementById("odd2").innerHTML = odd;
    } else if (id == 3) {
        document.getElementById("odd3").innerHTML = odd;
    } else if (id == 4) {
        document.getElementById("odd4").innerHTML = odd;
    } else if (id == 5) {
        document.getElementById("odd5").innerHTML = odd;
    } else if (id == 6) {
        document.getElementById("odd6").innerHTML = odd;
    } 
    value1 = document.getElementById("odd1").innerHTML;
    value2 = document.getElementById("odd2").innerHTML;
    value3 = document.getElementById("odd3").innerHTML;
    value4 = document.getElementById("odd4").innerHTML;
    value5 = document.getElementById("odd5").innerHTML;
    value6 = document.getElementById("odd6").innerHTML;
    wild_value = document.getElementById("wild").innerHTML;
    console.log(value1, value2, value3, value4, value5, value6, wild_value);
    wild_value = 1000 - parseInt(value1) - parseInt(value2) - parseInt(value3) - parseInt(value4) - parseInt(value5) - parseInt(value6); 
}

function randomizer(stats) {
    let  max = 1000;
    const tiles = document.getElementsByClassName("tile");
    const parent = document.getElementsByClassName("slot-machine");

    const winDisplay = document.getElementById("win_amount");

    winDisplay.innerHTML = "";
    
    for (const tile of tiles) {
        if (tile.parentElement == parent[0].children[0]) {
            max = stats[5];
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
        } else {
            symbol = "WILD_ICON.png";
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
    win_amount = win();
    UpdateBalance(20, win_amount);
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
