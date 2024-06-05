function loadProofChoose() {
    // Hole das ausgewählte Element aus dem Dropdown-Menü
    var selectedNumber = document.getElementById("number_of_proofs").value;

    // Holen Sie den Container, in dem die Formulare platziert werden sollen
    var container = document.getElementById("container");

    // Lösche alle vorhandenen Elemente im Container
    container.innerHTML = "";

    // Lade die HTML-Datei mit den Input-Formularen
    fetch("/static/choose_proof.html")

        .then(response => response.text())
        .then(html => {
            // Erzeuge ein temporäres Element, um den HTML-Code zu parsen
            var temp = document.createElement('div');
            temp.innerHTML = html;

            // Wiederhole den Vorgang basierend auf der ausgewählten Zahl
            for (var i = 0; i < selectedNumber; i++) {
                // Klonen Sie das gewünschte Input-Formular aus der geladenen HTML-Datei
                var inputForm = temp.querySelector('.choose_proof').cloneNode(true);

                inputForm.querySelector(".get_id").id = "container" + i ;
                inputForm.querySelector(".form-select").id = i ;
                

                // Ändere den Platzhaltertext, wenn erforderlich
                //inputForm.querySelector('input').placeholder = "Feld " + (i + 1);

                // Füge das Input-Formular zum Container hinzu
                container.appendChild(inputForm);

               // var newForm = container.querySelectorAll('.choose_proof')[i];

                //var addMoreButton = newForm.querySelector('.addMoreButton');
                
            }
        });
}


function loadProofForms(id) {
    // Hole das ausgewählte Element aus dem Dropdown-Menü
    var selectedProof = document.getElementById(id).value;

    // Holen Sie den Container, in dem die Formulare platziert werden sollen
    var container = document.getElementById("container"+id);

    // Lösche alle vorhandenen Elemente im Container
    container.innerHTML = "";

    var string_proof = "" ; 
    
    if (selectedProof == 1) {
        string_proof = "/static/range_proof.html" ; 
    }else if (selectedProof == 2){
        string_proof = "/static/set_membership_proof.html" ;
    }else if (selectedProof == 3) {
        string_proof = "/static/uniqueness_proof.html" ; 
    }
    

    // Lade die HTML-Datei mit den Input-Formularen
    fetch(string_proof)

        .then(response => response.text())
        .then(html => {
            // Erzeuge ein temporäres Element, um den HTML-Code zu parsen
            var temp = document.createElement('div');
            temp.innerHTML = html;
            var inputForm = temp.querySelector('.selected_proof').cloneNode(true);



            container.appendChild(inputForm);

        });
}


// script.js

document.addEventListener('DOMContentLoaded', function () {
    var codeSnippet = document.getElementById('codeSnippet');
    var downloadLink = document.getElementById('downloadLink');

    // Hier deinen Code einfügen
    var codeContent = 'console.log("Hello, World!");\n// Weitere Code-Zeilen...';

    codeSnippet.textContent = codeContent;
    downloadLink.href = 'data:text/plain;charset=utf-8,' + encodeURIComponent(codeContent);
});

function copyCode() {
    var codeSnippet = document.getElementById('codeSnippet');

    // Kopieren in die Zwischenablage
    new ClipboardJS('.btn', {
        text: function () {
            return codeSnippet.textContent;
        }
    });
}



function generateCode() {

    var number_of_proofs = document.getElementById("number_of_proofs").value;

    var generatedCode = 'import "hashes/sha256/512bitPadded.code" as sha256; \n' 
    generatedCode += 'from "ecc/babyjubjubParams" import BabyJubJubParams; \n'
    generatedCode += 'import "signatures/verifyEddsa.code" as verifyEddsa; \n'
    generatedCode += 'import "ecc/babyjubjubParams.code" as context; \n'
    generatedCode += 'def main(u32 min, u32 max, u32 [8] attr, private u32 [8] vc, private field[2] R, private field S, field[2] A, u32[8] M0, u32[8] M1) -> bool{ \n'
    generatedCode += '//Verify Signature (R,S) with PupKey (A) on Hash (M0, M1) \n'
    generatedCode += 'BabyJubJubParams context = context(); \n'
    generatedCode += 'bool isVerified = verifyEddsa(R, S, A, M0, M1, context); \n'
    generatedCode += 'u32[8] hash1 = sha256(attr, vc); \n'
    generatedCode += '// M0 is the first 32 bytes of sha256(input 1 || vc) || sha256(attr || vc) \n'
    generatedCode += 'bool hashcheck = hash1 == M0; \n'
    generatedCode += 'bool rangeCheck = vc[7] >= min && vc[7] <= max; \n'
    generatedCode += 'bool r = isVerified && hashcheck && rangeCheck; \n'
    generatedCode += 'return r; \n'

  
    

    for (var i = 0; i < number_of_proofs; i++) {
        
        var selectedProof = document.getElementById("container"+i) ;
        var innerDiv = selectedProof.querySelector("div");

        
        var allClasses = innerDiv.classList;

        // Convert classList to an array for easier manipulation
        var classesArray = Array.from(allClasses);

        console.log(classesArray)

        if (classesArray[1] === "range_proof"){
            console.log("range_proof")
            
            // var innerDiv = outerDiv.querySelector("div");



        }
        else if (classesArray[1] === "set_membership_proof"){
            console.log("set_membership_proof")
        }
        else if (classesArray[1] === "uniqueness_proof"){
            console.log("uniqueness_proof")
        }

        // Now you can loop through the classesArray to see all classes
        //classesArray.forEach(function(className) {
            //console.log(className);
        //});


    }
        
    //if (checkbox1Checked) {
        //generatedCode += "Checkbox 1 wurde ausgewählt.\n";
    //}

    document.getElementById("codeSnippet").textContent = generatedCode;
}





