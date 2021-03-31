import { LightningElement } from 'lwc';

export default class ToastMessage extends LightningElement {


    success(title, ID, message) {

        this.dispatchEvent(
            new ShowToastEvent({
                title: `Success ${title}`,
                message: `Record ID${ID} ${message}`,
                variant: 'success'
            })
        );


    }





}