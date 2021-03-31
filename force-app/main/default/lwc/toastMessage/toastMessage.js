import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// export { successToast, errorToast };

/**
 * Used on CRUD operaions. Show success toast message, with CRUD record ID
 * @param {String} title mesage,added to default title 
 * @param ID record ID
 * @param message 
 */

export function successToast(title = '', ID = '', message = '') {
    dispatchEvent(
        new ShowToastEvent({
            title: `Success ${title}`,
            message: `Record ID${ID} ${message}`,
            variant: 'success'
        })
    );
}

/**
 * Show error toast message
 * @param  title 
 * @param  message 
 */
export function errorToast(title = '', message = '') {
    dispatchEvent(
        new ShowToastEvent({
            title: `Error ${title}`,
            message: message,
            variant: 'error'
        })
    );
}


