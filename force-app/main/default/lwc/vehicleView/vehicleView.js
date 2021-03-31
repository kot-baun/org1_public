
import { LightningElement, wire, track, api } from 'lwc';
import getWrappedRecords from '@salesforce/apex/VehicleViewController.getWrappedRecords';
import { errorToast } from 'c/toastMessage';

//filter
const ALL = 'All';
const NOT_AVAILABLE_STATUS = 'Not Available';
const AT_SERVICE_STATUS = 'At Service';
const AVAILABLE_STATUS = 'Available';
const filterOptions = [
    { value: ALL, label: ALL },
    { value: AVAILABLE_STATUS, label: AVAILABLE_STATUS },
    { value: NOT_AVAILABLE_STATUS, label: NOT_AVAILABLE_STATUS },
    { value: AT_SERVICE_STATUS, label: AT_SERVICE_STATUS },
];
//datatable
const RECORD_DETAIL = 'recordDetail';
const COLUMNS = [
    // { label: 'ID', fieldName: 'id', type: 'text' },
    { label: 'Model description', fieldName: 'vehicleDescription', type: 'text' },
    { label: 'Plate number', fieldName: 'plateNumber', type: 'text', editable: true },
    { label: 'Status', fieldName: 'status', type: 'text' },
    { label: 'Maintenance date', fieldName: 'lastMaintenanceDate', type: 'date' },
    { label: 'Driver name', fieldName: 'driverName', type: 'text' },
    {
        type: 'button', label: 'Detail',
        typeAttributes: { label: 'detail >> ', name: RECORD_DETAIL, title: 'Show vehicle details', },
        cellAttributes: { alignment: 'right' }
    },
];

export default class VehicleView extends LightningElement {
    //datatable
    columns = COLUMNS;
    //combobox selected value
    filterValue = ALL;
    get filterOptions() { return filterOptions; }

    @track vehicles;
    @track error;

    refresh;
    @wire(getWrappedRecords, { status: '$filterValue' }) wiredRecord(result) {
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

    /**
     * Select one vehicle from datatble, and get it's ID. Fire an event to send a selected vehicle Id to the vehicleContainer
     * @param event 
     */
    handleRowAction(event) {
        const selectedRow = event.detail.row;
        const actionName = event.detail.action.name;
        switch (actionName) {
            case RECORD_DETAIL:
                // Fire the event from vehicleView to vehicleContainer
                this.dispatchEvent(new CustomEvent('vehicleselected', {
                    detail: this.vehicles.find(v => v.id === selectedRow.id)
                }));
                break;
        }
    }

    /**
     * Handle filter value change, this will trigger a request to the server
     * and update the shown data 
     * @param event 
     */
    handleFilter(event) {
        try {
            this.filterValue = event.detail.value;
        } catch (error) {
            errorToast('on update records after CRUD', error.message);
        }

    }
}