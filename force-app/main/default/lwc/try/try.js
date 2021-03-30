import { LightningElement, track, wire } from 'lwc';
import getWrappedRecords from '@salesforce/apex/VehicleViewController.getWrappedRecords';
const ALL = 'All';
const RECORD_DETAIL = 'recordDetail';

const COLUMNS = [
    { label: 'ID', fieldName: 'id', type: 'text' },
    { label: 'Model description', fieldName: 'vehicleDescription', type: 'text' },
    { label: 'Plate number', fieldName: 'plateNumber', type: 'text', editable: true },
    { label: 'Status', fieldName: 'status', type: 'text' },
    { label: 'Date', fieldName: 'lastMaintenanceDate', type: 'date' },
    { label: 'Driver name', fieldName: 'driverName', type: 'text' },
    {
        type: 'button', label: 'Detail', typeAttributes:
        {
            label: 'detail >> ',
            name: RECORD_DETAIL,
            title: 'editTitle',
            disabled: false,
            value: 'test',
        }
    },
];

export default class Try extends LightningElement {
    columns = COLUMNS;

    filterValue = ALL;
    @track vehicles;
    @track error;

    refresh;
    @wire(getWrappedRecords, { status: '$filterValue' })
    wiredRecord(result) {
        this.refresh = result;
        if (result.data) {
            this.vehicles = result.data;
            this.error = undefined;
        }
        if (result.error) {
            this.vehicles = undefined;
            this.error = result.error;
        }
    }



    handleClick(event) {
        console.log('refresh' + JSON.stringify(this.refresh));
        console.log('vehicles' + JSON.stringify(this.vehicles));
        console.log('err' + JSON.stringify(this.error));

    }


    handleRowAction(event) { }

}