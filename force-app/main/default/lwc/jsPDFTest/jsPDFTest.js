import { LightningElement } from 'lwc';
import JSPDF from '@salesforce/resourceUrl/jspdf';
import { loadScript } from 'lightning/platformResourceLoader';
export default class JsPDFTest extends LightningElement {
    //jsPdfInitialized=false;
    renderedCallback(){
      //  if (this.jsPdfInitialized) {
        //    return;
        //}
        //this.jsPdfInitialized = true;

        Promise.all([  loadScript(this, loadScript(JSPDF))]);
    }
    
   
    generate()
    {
        try
        {
            const { jsPdf } = window.jspdf;

            const doc = new jsPdf(); 
            doc.text("Hello SalesforceCodex!", 10, 10);
            doc.save("a4.pdf");
            
        }
        catch(error) {
            alert("Error " + error);
        }
    }
    
    generatePDF()
    {
        this.generate();
    }

    
  
}