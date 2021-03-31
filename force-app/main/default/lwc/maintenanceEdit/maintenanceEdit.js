import { LightningElement, api, track } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import MAINTENANCCE_OBJECT from '@salesforce/schema/Maintenance__c';

export default class MaintenanceEdit extends NavigationMixin(LightningElement) {
    //modal dialog visibility
    @api bShowModal = false;
    objectApiName = MAINTENANCCE_OBJECT;
    @api vehicleId;
    @api maintenanceId;


    openModal() { this.bShowModal = true; }
    closeModal() { this.bShowModal = false; }
    @api editModal(vId, mId) {
        this.bShowModal = true;
        this.vehicleId = vId;
        this.maintenanceId = mId;
    }

    /**
     * Delete maintenance record, with maintenanceId
     */
    handlerManintenanceDelete(event) {
        deleteRecord(this.maintenanceId)
            .then(() => {
                this.successToast('', this.maintenanceId, 'deleted');
                this.closeModal();
                //call update maintenance data on maintenanceView
                this.dispatchEvent(new CustomEvent("update", { detail: 'update' }));
            })
            .catch(error => {
                this.errorToast('deleting', error.message);
            });
    }

    /**
     * Handler to show success message on maintenance update. Requests updated maintenance data to view   
     */
    handleSuccess(event) {
        this.successToast('maintenance created', event.detail.id);
        this.closeModal();
        //call update maintenance data on maintenanceView
        this.dispatchEvent(new CustomEvent("update", { detail: 'update' }));
    }

    /**
     * Handler to show error message on maintenance CRUD, and its reason
     * @param event 
     */
    handleError(event) {
        this.errorToast('on mainteannce edit', event.detail);
        this.dispatchEvent(toastEvent);
        this.showNew = false;
    }



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
