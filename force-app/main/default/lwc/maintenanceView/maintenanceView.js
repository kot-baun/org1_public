import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { refreshApex } from '@salesforce/apex';

import getRecords from '@salesforce/apex/MaintenanceViewController.getRecords';
// import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import MAINTENANCCE_OBJECT from '@salesforce/schema/Maintenance__c';
import ID_FIELD from '@salesforce/schema/Maintenance__c.Id';
import FROM_DATE_FIELD from '@salesforce/schema/Maintenance__c.Maintenance_from_date__c';
import ACTUAL_DATE_FIELD from '@salesforce/schema/Maintenance__c.Maintenance_date__c';
import STATUS_FIELD from '@salesforce/schema/Maintenance__c.Maintenance_status__c';
import SERVICE_FIELD from '@salesforce/schema/Maintenance__c.Maintenance_Service__c';
import VEHICLE_FIELD from '@salesforce/schema/Maintenance__c.Vehicle__c';

import SERVICE_NAME_FIELD from '@salesforce/schema/Maintenance__c.Maintenance_Service__r.Name';



const COLUMNS = [
    { label: 'ID', fieldName: ID_FIELD.fieldApiName, type: 'text' },
    { label: 'From date', fieldName: FROM_DATE_FIELD.fieldApiName, type: 'date' },
    { label: 'Real date', fieldName: ACTUAL_DATE_FIELD.fieldApiName, type: 'date' },
    { label: 'Status', fieldName: STATUS_FIELD.fieldApiName, type: 'text' },
    { label: 'Service', fieldName: SERVICE_NAME_FIELD.fieldApiName, type: 'text' },
    {
        type: 'button', label: 'Detail', typeAttributes:
        {
            label: 'Edit ',
            name: 'Edit',
            title: 'editTitle',
            disabled: false,
            value: 'test',
        }
    },
];



export default class MaintenanceView extends LightningElement {
    //VehicleId, obtained from the vehicle detail. Used to query the service data of the current vehicle from the server 
    @api vehicleId;
    //datatble
    columns = COLUMNS;
    //new maintenance dialog
    showNew = false;
    @track maintenances;
    @track error;
    @track wireMaintenances = [];
    refreshMaintenance;
    @wire(getRecords, { targetVehicleId: '$vehicleId' })
    wiredRecord(result) {
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

    //--------------------------------     begin new maintenance     //--------------------------------

    objectApiName = MAINTENANCCE_OBJECT;
    fields = [FROM_DATE_FIELD, SERVICE_FIELD];

    /**
     * Show and hide a new maintenance record dialog with lightning-record-edit-form
     * @param event 
     */
    handleShowNewDialog(event) {
        if (!this.showNew) {
            this.showNew = true;
        } else {
            this.showNew = false;
        }
        const inputFields = this.template.querySelectorAll('lightning-input-field').reset();

    }

    /**
     * Handler to show success message on maintenance creation. Requests updated maintenance data
     * @param  event 
     */

    handleSuccess(event) {
        console.log(JSON.stringify(event.detail));
        const toastEvent = new ShowToastEvent({
            title: "Mainteannce created",
            message: "Record ID: " + event.detail.id,
            variant: "success"
        });
        console.log('contact creation success');
        this.dispatchEvent(toastEvent);
        try {
            refreshApex(this.refreshMaintenance);
        } catch (error) {
            console.log("error catched " + error.name);
            console.log(error.message);
            console.log(error.stack);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        } finally {
            this.showNew = false;
        }

    }
    /**
     * Handler to show error message on maintenance creation, and its reason
     * @param event 
     */
    handleError(event) {
        console.log(JSON.stringify(event.detail));
        const toastEvent = new ShowToastEvent({
            title: "Error on mainteannce creation",
            message: "Record ID: " + event.detail,
            variant: "error"
        });
        console.log('Mainteannce creation error');
        this.dispatchEvent(toastEvent);
        this.showNew = false;
    }

    //--------------------------------     end new maintenance     //--------------------------------

    //--------------------------------     begin select maintenance ID     //--------------------------------
    miantenanceId = undefined;
    /**
     * Select one maintenance from datatble, and get it's ID. Used to CRUD operaton on selected maintenance
     * @param  event 
     */
    handleRowAction(event) {
        const selectedRow = event.detail.row;
        const actionName = event.detail.action.name;
        console.log(actionName + ' row ->   ' + JSON.stringify(selectedRow));
        console.log("ID " + selectedRow.Id);

        switch (actionName) {
            case 'Edit':
                console.log(selectedRow.Id);
                //call to the maintenanceEdit componnet
                this.template.querySelector('c-maintenance-edit').editModal(this.vehicleId, selectedRow.Id);
                break;
        }
    }

    /**
     * Handling an update call from a maintenanceEdit componet after a successful CRUD operation on a maintenance record. 
     * Requests updated maintenance data
     * @param  event 
     */
    handleUpdate(event) {
        console.log('handle success');
        try {
            refreshApex(this.refreshMaintenance);
        } catch (error) {
            console.log("error catched " + error.name);
            console.log(error.message);
            console.log(error.stack);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        }
    }




}

