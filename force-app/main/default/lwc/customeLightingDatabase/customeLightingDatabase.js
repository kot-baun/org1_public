import LightningDatatable from 'lightning/datatable';
import maintenanceEditTemplate from './maintenanceEditTemplate';

export default class CustomeLightingDatabase extends LightningDatatable {

    static customTypes = {
        maintenanceEditTemplate: {
            template: maintenanceEditTemplate,
            typeAttributes: ['label', 'vehicleId', 'maintenanceId']
        }



    }



}