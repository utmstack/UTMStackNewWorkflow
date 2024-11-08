import {Component, OnDestroy, OnInit} from '@angular/core';
import {ActivatedRoute} from '@angular/router';
import {NgxSpinnerService} from 'ngx-spinner';
import {Subject} from 'rxjs';
import {map, takeUntil} from 'rxjs/operators';
import {UtmModulesEnum} from '../../app-module/shared/enum/utm-module.enum';
import {UtmModuleType} from '../../app-module/shared/type/utm-module.type';
import {AccountService} from '../../core/auth/account.service';
import {UtmToastService} from '../../shared/alert/utm-toast.service';
import {MenuBehavior} from '../../shared/behaviors/menu.behavior';
import {TimeFilterBehavior} from '../../shared/behaviors/time-filter.behavior';
import {
  ALERT_GLOBAL_FIELD,
  ALERT_NAME_FIELD,
  ALERT_SEVERITY_FIELD_LABEL,
  ALERT_TIMESTAMP_FIELD
} from '../../shared/constants/alert/alert-field.constant';
import {HIGH_TEXT, LOW_TEXT, MEDIUM_TEXT} from '../../shared/constants/alert/alert-severity.constant';
import {ALERT_ROUTE, LOG_ROUTE} from '../../shared/constants/app-routes.constant';
import {TIME_DASHBOARD_REFRESH} from '../../shared/constants/time-refresh.const';
import {IndexPatternSystemEnumID, IndexPatternSystemEnumName} from '../../shared/enums/index-pattern-system.enum';
import {OverviewAlertDashboardService} from '../../shared/services/charts-overview/overview-alert-dashboard.service';
import {IndexPatternService} from '../../shared/services/elasticsearch/index-pattern.service';
import {LocalFieldService} from '../../shared/services/elasticsearch/local-field.service';
import {ExportPdfService} from '../../shared/services/util/export-pdf.service';
import {RefreshService, RefreshType} from '../../shared/services/util/refresh.service';
import {ChartSerieValueType} from '../../shared/types/chart-reponse/chart-serie-value.type';
import {ElasticFilterType} from '../../shared/types/filter/elastic-filter.type';
import {UtmIndexPatternFields} from '../../shared/types/index-pattern/utm-index-pattern-fields';
import {buildFormatInstantFromDate} from '../../shared/util/utm-time.util';

@Component({
  selector: 'app-dashboard-overview',
  templateUrl: './dashboard-overview.component.html',
  styleUrls: ['./dashboard-overview.component.scss']
})
export class DashboardOverviewComponent implements OnInit, OnDestroy {
  pdfExport = false;
  refreshTime = TIME_DASHBOARD_REFRESH;
  dailyAlert: ChartSerieValueType[] = [];
  loadingChartDailyAlert = true;
  refreshInterval = 30000;
  ALERT_ROUTE = ALERT_ROUTE;
  LOG_ANALYZER_ROUTE = LOG_ROUTE;
  // params
  paramsAlertSeverity = {};
  paramAlertSeverityCLick = ALERT_SEVERITY_FIELD_LABEL;

  tableTopAlertsParams = {};
  tableTopAlertsParamsClick = ALERT_NAME_FIELD;

  paramsEventByType = {
    // 'global.type.keyword': 'logx',
    '@timestamp': null,
    'dataType.keyword': null,
    patternId: IndexPatternSystemEnumID.LOG,
    indexPattern: IndexPatternSystemEnumName.LOG
  };
  paramEventByTypeCLick = 'dataType.keyword';

  paramsTopEvent = {
    // 'global.type.keyword': 'logx',
    '@timestamp': null,
    'dataType.keyword': 'wineventlog',
    'logx.wineventlog.event_name.keyword': null,
    patternId: IndexPatternSystemEnumID.LOG,
    indexPattern: IndexPatternSystemEnumName.LOG
  };
  paramEvenTopCLick = 'logx.wineventlog.event_name.keyword';
  alertSeverityColorMap: { value: string, color: string }[] = [
    {color: '#42A5F5', value: LOW_TEXT},
    {color: '#FF9800', value: MEDIUM_TEXT},
    {color: '#EF5350', value: HIGH_TEXT}];

  filters: ElasticFilterType[] = [];
  filterTime: { from: string, to: string };
  filtersValues: ElasticFilterType[] = [];
  destroy$: Subject<void> = new Subject();
  runList = 0;
  visualizationRender = 8;
  preparingPrint = true;
  RefreshType = RefreshType;
  timeOutId: any;


  constructor(private overviewAlertDashboardService: OverviewAlertDashboardService,
              private menuBehavior: MenuBehavior,
              private localFieldService: LocalFieldService,
              private indexPatternService: IndexPatternService,
              private accountService: AccountService,
              private spinner: NgxSpinnerService,
              private exportPdfService: ExportPdfService,
              private activatedRoute: ActivatedRoute,
              private timeFilterBehavior: TimeFilterBehavior,
              private utmToastService: UtmToastService,
              private refreshService: RefreshService) {
  }

  ngOnInit() {
    this.menuBehavior.$menu.next(false);
    window.addEventListener('beforeprint', (event) => {
      this.pdfExport = true;
    });
    window.addEventListener('afterprint', (event) => {
      this.pdfExport = false;
    });
    /**
     * SET ALERT PARAMS TO NAVIGATE
     */
    this.paramsAlertSeverity[ALERT_GLOBAL_FIELD] = 'ALERT';
    this.paramsAlertSeverity[ALERT_TIMESTAMP_FIELD] = null;
    this.paramsAlertSeverity[ALERT_SEVERITY_FIELD_LABEL] = null;

    this.tableTopAlertsParams[ALERT_GLOBAL_FIELD] = 'ALERT';
    this.tableTopAlertsParams[ALERT_TIMESTAMP_FIELD] = null;
    this.tableTopAlertsParams[ALERT_NAME_FIELD] = null;
    /**
     * END
     */

    // this.getDailyAlert();

    /**
     * Show activate modules modal on constructor
     * Why?? Because home route may change, but always load in this module
     */
    // this.utmOpenModuleModalService.find(1).subscribe(response => {
    //   if (!response.body.moduleModalShown) {
    //     const modal = this.modalService.open(AppModuleActivateModalComponent, {centered: true});
    //   }
    // });

    this.timeOutId = setTimeout(() => {
      this.synchronizeFields();
    }, 100000);

    this.timeFilterBehavior.$time
      .pipe(takeUntil(this.destroy$))
      .subscribe(time => {
        if (time) {
          this.filterTime = time;
        }
      });

    this.activatedRoute.queryParams.subscribe(params => {
      const queryParams = Object.entries(params).length > 0 ? params : null;
      if (queryParams) {
        this.filterTime = JSON.parse(queryParams.filterTime);
        setTimeout(() => {
          this.pdfExport = true;
          this.refreshInterval = null;
          this.timeFilterBehavior.$time.next(this.filterTime);
        }, 1000);
      }
    });
  }

  getActiveModuleStatus(modules: UtmModuleType[], moduleEnum: UtmModulesEnum): boolean {
    const index = modules.findIndex(value => value.moduleName === moduleEnum);
    return modules[index].moduleActive;
  }

  getDailyAlert() {
    this.loadingChartDailyAlert = true;
    this.overviewAlertDashboardService.getCardAlertTodayWeek().subscribe(response => {
      this.dailyAlert = response.body;
      this.loadingChartDailyAlert = false;
    });
  }

  getTimeFilterValue() {
    this.filterTime = {
      from: this.resolveFromDate(this.getTime()),
      to: this.resolveToDate(this.getTime()),
    };
  }

  getTime() {
    const indexTime = this.filters.findIndex(value => value.field === '@timestamp');
    if (indexTime !== -1) {
      return {
        from: this.filters[indexTime].value[0],
        to: this.filters[indexTime].value[1]
      };
    }
  }

  resolveToDate(date: { from: any, to: any }): string {
    if (!isNaN(Date.parse(date.to))) {
      return date.to;
    } else {
      return new Date().toString();
    }
  }

  resolveFromDate(date: { from: any, to: any }): string {
    if (!isNaN(Date.parse(date.from))) {
      return date.from;
    } else {
      return buildFormatInstantFromDate(date).timeFrom;
    }
  }

  /*exportToPdf() {
    this.pdfExport = true;
    // captureScreen('utmDashboardAlert').then((finish) => {
    //   this.pdfExport = false;
    // });
    setTimeout(() => {
      window.print();
    }, 1000);
  }
*/
  exportToPdf() {
    this.spinner.show('buildPrintPDF').then(() => {
      const params = this.filterTime
        ? `?filterTime=${encodeURIComponent(JSON.stringify(this.filterTime))}`
        : '';
      const url = `/dashboard/overview${params}`;

      this.exportPdfService.getPdf(url, 'Dashboard_Overview', 'PDF_TYPE_TOKEN').
      subscribe(response => {
        this.spinner.hide('buildPrintPDF').then(() => {
          this.pdfExport = false;
          this.exportPdfService.handlePdfResponse(response);
        });
      }, error => {
        this.spinner.hide('buildPrintPDF').then(() => {
          this.utmToastService.showError('Error', 'An error occurred while creating a PDF.');
        });
      });
    });
  }

  chartEvent($event: string) {
  }

  /**
   * Sync field in local storage from index service
   */
  synchronizeFields() {
    this.accountService.identity(true).then(value => {
      if (value) {
        this.indexPatternService.queryWithFields({page: 0, size: 2000, 'isActive.equals': true})
            .pipe(
                map(response => response.body))
            .subscribe((values: UtmIndexPatternFields[]) => {
              values.forEach(value => {
                if (value.fields && value.fields.length > 0) {
                  this.localFieldService.setPatternStoredFields(value.indexPattern, value.fields);
                }
              });
            });
      }
    });
  }

  onRun() {
    this.runList += 1;
    if (this.runList === this.visualizationRender) {
      console.log('All the visualizations data has loaded, waiting for rendering');
      setTimeout(() => this.preparingPrint = false, 3000);
      console.log('All the visualizations now has rendered');
    }
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
    this.refreshService.stopInterval();
    clearTimeout(this.timeOutId);
  }
}
