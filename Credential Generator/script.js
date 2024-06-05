// Speichere diese Datei als "script.js" oder einen anderen passenden Namen ab
//import { initialize, ZoKratesProvider } from "zokrates-js";

function downloadTextFile(data, filename) {
    const joined_data = data.join(" ")
    console.log(joined_data); 
    const blob = new Blob([joined_data], { type: 'text/plain' });
    const link = document.createElement('a');
    link.href = window.URL.createObjectURL(blob);
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
}


function handleButtonClick() {
    // Dropdown-Elemente abrufen
    var dropdown1 = document.getElementById("issuer");
    //var dropdown2 = document.getElementById("filename");


    // Ausgewählte Optionen abrufen
    var selectedOption1 = dropdown1.options[dropdown1.selectedIndex].value;
    //var selectedOption2 = dropdown2.options[dropdown2.selectedIndex].value;

    // Input-Elemente abrufen
    var input1 = document.getElementById("attribut_id").value;
    console.log(input1)
    var input2 = document.getElementById("attribut_wert").value;
    var input3 = document.getElementById("filename").value;

    // Annahme: Parameterwerte
    const parameter1 = input1;
    const parameter2 = input2;
    const parameter3 = selectedOption1;

    // API-Endpunkt mit Parametern
    const apiEndpoint = `http://127.0.0.1:5000/api/calculate?attrID=${parameter1}&attrWert=${parameter2}&issuer=${parameter3}`;

    // GET-Request mit Fetch-API
    fetch(apiEndpoint)
    .then(response => {
        if (!response.ok) {
        throw new Error(`HTTP error! Status: ${response.status}`);
        }
        return response.json();
    })
    .then(data => {
        console.log("API Response:", data);
        downloadTextFile(data.result, input3);
        //document.getElementById('result-container').innerText = 'Result: ' + data.result;
        // Hier kannst du mit den Daten weiterarbeiten, z.B. das Ergebnis in der UI anzeigen
    })
    .catch(error => {
        console.error("Fetch error:", error);
        // Hier kannst du Fehlerbehandlung implementieren
    });

}

