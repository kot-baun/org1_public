import { LightningElement, api, track } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';



import MAINTENANCCE_OBJECT from '@salesforce/schema/Maintenance__c';
import ID_FIELD from '@salesforce/schema/Maintenance__c.Id';
import FROM_DATE_FIELD from '@salesforce/schema/Maintenance__c.Maintenance_from_date__c';
import ACTUAL_DATE_FIELD from '@salesforce/schema/Maintenance__c.Maintenance_date__c';
import STATUS_FIELD from '@salesforce/schema/Maintenance__c.Maintenance_status__c';
import SERVICE_FIELD from '@salesforce/schema/Maintenance__c.Maintenance_Service__c';
import VEHICLE_FIELD from '@salesforce/schema/Maintenance__c.Vehicle__c';

import SERVICE_NAME_FIELD from '@salesforce/schema/Maintenance__c.Maintenance_Service__r.Name';




export default class ModalLwc extends NavigationMixin(LightningElement) {
    //modal dialog visibility
    @api bShowModal = false;
    objectApiName = MAINTENANCCE_OBJECT;
    @api vehicleId;
    @api maintenanceId;


    openModal() {
        this.bShowModal = true;
    }

    closeModal() {
        this.bShowModal = false;
    }

    @api editModal(vId, mId) {
        console.log('on editModal old maintenance ' + this.maintenanceId + ' new ' + mId + ' old vehicle ' + this.vehicleId + ' new  ' + vId);
        this.bShowModal = true;
        this.vehicleId = vId;
        this.maintenanceId = mId;
    }

    /**
     * Delete maintenance record, with maintenanceId
     * @param  event 
     */
    handlerManintenanceDelete(event) {
        deleteRecord(this.maintenanceId)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record deleted',
                        variant: 'success'
                    })
                );
                this.closeModal();
                //call update maintenance data on maintenanceView
                this.dispatchEvent(new CustomEvent("update", { detail: 'update' }));
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }


    /**
     * Handler to show success message on maintenance update.
     * @param  event 
     */
    handleSuccess(event) {
        console.log(JSON.stringify(event.detail));
        const toastEvent = new ShowToastEvent({
            title: "Mainteannce created",
            message: "Record ID: " + event.detail.id,
            variant: "success"
        });
        console.log('maintenance creation success');
        this.dispatchEvent(toastEvent);
        this.closeModal();
        //call update maintenance data on maintenanceView
        this.dispatchEvent(new CustomEvent("update", { detail: 'update' }));
    }

    /**
     * Handler to show error message on maintenance CRUD, and its reason
     * @param event 
     */
    handleError(event) {
        console.log(JSON.stringify(event.detail));
        const toastEvent = new ShowToastEvent({
            title: "Error on mainteannce creation",
            message: "Record ID: " + event.detail,
            variant: "error"
        });
        console.log('Mainteannce CRUD error');
        this.dispatchEvent(toastEvent);
        this.showNew = false;
    }


}
