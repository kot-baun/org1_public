import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { refreshApex } from '@salesforce/apex';

import MAINTENANCCE_OBJECT from '@salesforce/schema/Maintenance__c';
import getWrappedRecords from '@salesforce/apex/MaintenanceViewController.getWrappedRecords';

const COLUMNS = [
    // { label: 'ID', fieldName: 'id', type: 'text' },
    { label: 'Available from date', fieldName: 'fromDate', type: 'date' },
    { label: 'Real date', fieldName: 'actualDate', type: 'date' },
    { label: 'Status', fieldName: 'status', type: 'text' },
    { label: 'Service', fieldName: 'service', type: 'text' },
    { type: 'button', label: 'Detail', typeAttributes: { label: 'Edit ', name: 'Edit', } },
];

export default class MaintenanceView extends LightningElement {
    //VehicleId, obtained from the vehicle detail. Used to query the service data of the current vehicle from the server 
    @api vehicleId;
    //datatble
    columns = COLUMNS;
    //new maintenance dialog
    showNew = false;
    objectApiName = MAINTENANCCE_OBJECT;

    @track maintenances;
    @track error;

    refreshMaintenance;
    @wire(getWrappedRecords, { targetVehicleId: '$vehicleId' }) wiredRecord(result) {
        this.refreshMaintenance = result;
        if (result.data) {
            this.maintenances = result.data;
            this.error = undefined;
        }
        if (result.error) {
            this.maintenances = undefined;
            this.error = result.error;
        }
    }

    /**
     * Show and hide the new maintenance record dialog using the lightning-record-edit-form    
     */
    handleShowNewDialog(event) {
        this.showNew = !this.showNew;
        const inputFields = this.template.querySelectorAll('lightning-input-field').reset();
    }

    /**
     * Handler to show success message on maintenance creation. Requests updated maintenance data to view
     */
    handleSuccess(event) {
        try {
            this.successToast('maintenance created', event.detail.id);
            refreshApex(this.refreshMaintenance);
        } catch (error) {
            this.dispatchEvent('maintenance creation', error.message);
        } finally {
            this.showNew = false;
        }
    }
    /**
     * Handler to show error message on maintenance creation, and its reason
     * @param event 
     */
    handleError(event) {
        this.errorToast('on mainteannce creation', event.detail);
        this.showNew = false;
    }
    /**
     * Select one maintenance from datatble, and get it's ID. Used to CRUD operaton on selected maintenance
     * @param  event 
     */
    handleRowAction(event) {
        const selectedRow = event.detail.row;
        const actionName = event.detail.action.name;
        switch (actionName) {
            case 'Edit':
                //call to the maintenanceEdit componnet
                this.template.querySelector('c-maintenance-edit').editModal(this.vehicleId, selectedRow.id);
                break;
        }
    }
    /**
     * Handling an update call from a maintenanceEdit componet after a successful CRUD operation on a maintenance record. 
     * Requests updated maintenance data  
     */
    handleUpdate(event) {
        try {
            refreshApex(this.refreshMaintenance);
        } catch (error) {
            this.errorToast('on update records after CRUD', error.message);
        }
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

