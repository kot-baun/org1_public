import { LightningElement, api, track } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { successToast, errorToast } from 'c/toastMessage';

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
                successToast('', this.maintenanceId, 'deleted');
                this.closeModal();
                //call update maintenance data on maintenanceView
                this.dispatchEvent(new CustomEvent("update", { detail: 'update' }));
            })
            .catch(error => {
                errorToast('deleting', error.message);
            });
    }

    /**
     * Handler to show success message on maintenance update. Requests updated maintenance data to view   
     */
    handleSuccess(event) {
        try {
            successToast('maintenance update', event.detail.id);
            this.closeModal();
            //call update maintenance data on maintenanceView
            this.dispatchEvent(new CustomEvent("update", { detail: 'update' }));
        } catch (error) {
            console.log(error);
            console.log(JSON.stringify(error));
        }
    }

    /**
     * Handler to show error message on maintenance CRUD, and its reason
     * @param event 
     */
    handleError(event) {
        errorToast('on mainteannce edit', event.detail);
        this.dispatchEvent(toastEvent);
        this.showNew = false;
    }






}
