import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// export default class ToastMessage extends LightningElement {



const successToast = (title = '', ID = '', message = '') => {
    console.log('point1');
    dispatchEvent(
        new ShowToastEvent({
            title: `Success ${title}`,
            message: `Record ID${ID} ${message}`,
            variant: 'success'
        })
    );
    console.log('point2');
}
const errorToast = (title = '', message = '') => {
    this.dispatchEvent(
        new ShowToastEvent({
            title: `Error ${title}`,
            message: message,
            variant: 'error'
        })
    );
}

export { successToast, errorToast };



// }