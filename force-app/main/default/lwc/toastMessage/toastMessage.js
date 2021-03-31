import { LightningElement } from 'lwc';

export default class ToastMessage extends LightningElement {



    successToast(title = '', ID = '', message = '') {
        this.dispatchEvent(
            new ShowToastEvent({
                title: `Success ${title}`,
                message: `Record ID${ID} ${message}`,
                variant: 'success'
            })
        );
    }
    errorToast(title = '', message = '') {
        this.dispatchEvent(
            new ShowToastEvent({
                title: `Error ${title}`,
                message: message,
                variant: 'error'
            })
        );
    }




}