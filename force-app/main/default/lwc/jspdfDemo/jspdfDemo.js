/**
 * Created by gerry on 2/23/2021.
 */

import {LightningElement,api,wire,track} from 'lwc';
import {loadScript} from "lightning/platformResourceLoader";
import JSPDF from '@salesforce/resourceUrl/jspdf';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
const FIELDS = [
  'Contact.Id','Contact.Name',  'Contact.Account.Name'
];

export default class JspdfDemo extends LightningElement {
    @track name;
    @track accountName;
    @api recordId;
    @wire(getRecord, {
        recordId: "$recordId",
        fields:FIELDS
      })
      contactData({data,error}){
        if(data){
          console.log('data'+JSON.stringify(data))
          this.name=getFieldValue(data,'Contact.Name');
          this.accountName=getFieldValue(data,'Contact.Account.Name')
        }
        else if(error){
          console.log(error)
        }
      }
  /*contactList = [];
	headers = this.createHeaders([
		"Id",
		"FirstName",
		"LastName"
	]);  */
    renderedCallback(){
        if (this.jsPdfInitialized) {
            return;
        }
        this.jsPdfInitialized = true;

        Promise.all([
            loadScript(this, JSPDF)
        ]);
    }

	generatePdf(){
		const { jsPDF } = window.jspdf;
		const doc = new jsPDF({
	
		});

		doc.text("Hi I'm Matt", 20, 20);      
       
        //doc.setFont('arial black')
        doc.text("Account Name:", 20, 40)
       doc.text("Contact Name:", 20, 50) 
       
        doc.text(this.accountName, 60, 40)
        doc.text(this.name, 60, 50)

		doc.save("demo.pdf");
	}

	generateData(){
		//getContacts().then(result=>{
		//	this.contactList = result;
			this.generatePdf();
		//});
	}

	/*createHeaders(keys) {
		var result = [];
		for (var i = 0; i < keys.length; i += 1) {
			result.push({
				id: keys[i],
				name: keys[i],
				prompt: keys[i],
				width: 65,
				align: "center",
				padding: 0
			});
		}
		return result;
	}  */

}