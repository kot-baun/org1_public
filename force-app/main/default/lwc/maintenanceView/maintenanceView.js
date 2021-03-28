import { LightningElement, wire, api } from 'lwc';
import getRecords from '@salesforce/apex/MaintenanceViewController.getRecords';
import ID_FIELD from '@salesforce/schema/Maintenance__c.Id';

import FROM_DATE_FIELD from '@salesforce/schema/Maintenance__c.Maintenance_from_date__c';
import ACTUAL_DATE_FIELD from '@salesforce/schema/Maintenance__c.Maintenance_date__c';
import STATUS_FIELD from '@salesforce/schema/Maintenance__c.Maintenance_status__c';
import SERVICE_NAME_FIELD from '@salesforce/schema/Maintenance__c.Maintenance_Service__r.Name'

const COLUMNS = [
    { label: 'ID', fieldName: ID_FIELD.fieldApiName, type: 'text' },
    { label: 'Date', fieldName: ACTUAL_DATE_FIELD.fieldApiName, type: 'date' },
    { label: 'Status', fieldName: STATUS_FIELD.fieldApiName, type: 'text' },
    { label: 'Service', fieldName: SERVICE_NAME_FIELD.fieldApiName, type: 'text' }
];



export default class MaintenanceView extends LightningElement {
    @api vehicleId;
    columns = COLUMNS;
    @wire(getRecords, { targetVehicleId: '$vehicleId' }) maintenances;



    handleClick(event) {
        // console.log('maintenances ' + JSON.stringify(this.maintenances));
        // console.log("colums : " + JSON.stringify(this.columns));
        console.log("vehiucle ID " + this.vehicleID);
    }
}