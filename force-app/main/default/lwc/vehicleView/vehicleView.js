
import { LightningElement, wire } from 'lwc';
import getRecords from '@salesforce/apex/VehicleViewController.getRecords';
import ID_FIELD from '@salesforce/schema/Vehicle__c.Id';
import MODEL_FIELD from '@salesforce/schema/Vehicle__c.Vehicle_model_description__c';
import PLATE_FIELD from '@salesforce/schema/Vehicle__c.Vehicle_plate_number__c';

import DRIVER_NAME_FIELD from '@salesforce/schema/Vehicle__c.Vehicle_driver__r.Name';
import DRIVER_PHONE_FIELD from '@salesforce/schema/Vehicle__c.Vehicle_driver_contact_phone_reader__c';
import STATUS_FIELD from '@salesforce/schema/Vehicle__c.Vehicle_Status__c';
import TYPE_FIELD from '@salesforce/schema/Vehicle__c.Vehicle_Type__c';
import ACTUAL_DATE_FIELD from '@salesforce/schema/Vehicle__c.Vehicle_Last_Maintenance_Date__c';


//const
const RECORD_DETAIL = 'recordDetail';

const actions = [
    { label: 'Show details', name: 'show_details' },
    { label: 'Delete', name: 'delete' }
];

const COLUMNS = [
    { label: 'ID', fieldName: ID_FIELD.fieldApiName, type: 'text' },
    { label: 'Model description', fieldName: MODEL_FIELD.fieldApiName, type: 'text' },
    { label: 'Plate number', fieldName: PLATE_FIELD.fieldApiName, type: 'text', editable: true },
    { label: 'Status', fieldName: STATUS_FIELD.fieldApiName, type: 'text' },
    // { type: 'action', typeAttributes: { rowActions: actions } },
    {
        type: 'button', label: 'Detail', typeAttributes:
        {
            label: 'detail -> ',
            name: RECORD_DETAIL,
            title: 'editTitle',
            disabled: false,
            value: 'test',
        }
    },
    { label: 'Date', fieldName: ACTUAL_DATE_FIELD.fieldApiName, type: 'date' },



];
export default class VehicleView extends LightningElement {
    vehicle;
    columns = COLUMNS;
    @wire(getRecords) vehicles;

    handleRowAction(event) {

        const selectedRow = event.detail.row;

        const actionName = event.detail.action.name;
        console.log(actionName + ' row ->   ' + JSON.stringify(selectedRow));
        console.log('data ' + JSON.stringify(this.vehicles.data.find(v => v.Id === selectedRow.Id)));

        switch (actionName) {


            case RECORD_DETAIL:
                console.log(selectedRow.Id);
                // This component wants to emit a productselected event to its parent
                const evt = new CustomEvent('vehicleselected', {
                    // detail: event.detail
                    detail: this.vehicles.data.find(v => v.Id === selectedRow.Id)
                });
                // Fire the event from c-list
                this.dispatchEvent(evt);
                break;
        }

    }
    getSelectedName(event) {
        console.log('get');

        const selectedRows = event.detail.selectedRows;
        // Display that fieldName of the selected rows
        for (let i = 0; i < selectedRows.length; i++) {
            console.log("You selected: " + selectedRows[i].Id);
        }
    }
    getSelected() {
        console.log('click');
        console.log("getSelectedRows => ", this.template.querySelector('c-datatable').getSelectedRows());
    }
    handleClick(event) {
        console.log('click');
    }

}