package views
{
    import com.carrier.data.*;
    import com.carrier.events.*;
    import com.carrier.managers.*;
    import com.carrier.net.*;
    import components.*;
    import flash.events.*;
    import mx.binding.*;
    import mx.core.*;
    import mx.events.*;
    import mx.states.*;
    import mx.styles.*;
    import spark.components.*;
    import spark.layouts.*;
    import spark.primitives.*;
    import spark.utils.*;

    public class WebLoadingView extends View implements IStateClient2 {
        public var _WebLoadingView_BusyIndicatorContainer1:BusyIndicatorContainer;
        private var _1904040425bryantLogo:MultiDPIBitmapSource;
        private var _768156477carrierLogo:MultiDPIBitmapSource;
        private var _1580939664logoImage:BitmapImage;
        private var __moduleFactoryInitialized:Boolean = false;
        private var _embed_mxml_res_xhdpi_carrierLogo_png_269914967:Class;
        private var _embed_mxml_res_hdpi_bryantLogo1_png_1227507099:Class;
        private var _embed_mxml_res_xhdpi_bryantLogo1_png_282635123:Class;
        private var _embed_mxml_res_mdpi_bryantLogo1_png_1361880407:Class;
        private var _embed_mxml_res_mdpi_carrierLogo_png_1764377911:Class;
        private var _embed_mxml_res_hdpi_carrierLogo_png_1521018199:Class;
        private static var _skinParts:Object = {contentGroup:false};

        public function WebLoadingView() {
            this._embed_mxml_res_xhdpi_carrierLogo_png_269914967 = WebLoadingView__embed_mxml_res_xhdpi_carrierLogo_png_269914967;
            this._embed_mxml_res_hdpi_bryantLogo1_png_1227507099 = WebLoadingView__embed_mxml_res_hdpi_bryantLogo1_png_1227507099;
            this._embed_mxml_res_xhdpi_bryantLogo1_png_282635123 = WebLoadingView__embed_mxml_res_xhdpi_bryantLogo1_png_282635123;
            this._embed_mxml_res_mdpi_bryantLogo1_png_1361880407 = WebLoadingView__embed_mxml_res_mdpi_bryantLogo1_png_1361880407;
            this._embed_mxml_res_mdpi_carrierLogo_png_1764377911 = WebLoadingView__embed_mxml_res_mdpi_carrierLogo_png_1764377911;
            this._embed_mxml_res_hdpi_carrierLogo_png_1521018199 = WebLoadingView__embed_mxml_res_hdpi_carrierLogo_png_1521018199;
            mx_internal::_document = this;
            this.actionBarVisible = false;
            this.currentState = "default";
            this.tabBarVisible = false;
            this.layout = this._WebLoadingView_BasicLayout1_c();
            this.mxmlContentFactory = new DeferredInstanceFromFunction(this._WebLoadingView_Array2_c);
            this._WebLoadingView_MultiDPIBitmapSource2_i();
            this._WebLoadingView_MultiDPIBitmapSource1_i();
            this.addEventListener("creationComplete", this.___WebLoadingView_View1_creationComplete);
            var _loc_1:* = new DeferredInstanceFromFunction(this._WebLoadingView_BusyIndicatorContainer1_i);
            states = [new State({name:"default", overrides:[]}), new State({name:"loading", overrides:[new AddItems().initializeFromObject({itemsFactory:_loc_1, destination:null, position:"after", relativeTo:["logoImage"]})]})];
            return;
        }
        override public function set moduleFactory(param1:IFlexModuleFactory) : void {
            var factory:* = param1;
            super.moduleFactory = factory;
            if (this.__moduleFactoryInitialized){
                return;
            }
            this.__moduleFactoryInitialized = true;
            if (!this.styleDeclaration){
                this.styleDeclaration = new CSSStyleDeclaration(null, styleManager);
            }
            this.styleDeclaration.defaultFactory = function () : void {
                this.backgroundAlpha = 0;
                return;
            }            ;
            return;
        }
        override public function initialize() : void {
            super.initialize();
            return;
        }
        protected function creationCompleteHandler(event:FlexEvent) : void {
            var targetUsername:String;
            var targetSecret:String;
            var targetPopup:AlertPopupContainer;
            var event:* = event;
            this.currentState = "loading";
            if (Model.BRAND_CARRIER == "bryant"){
                this.logoImage.horizontalCenter = 20;
                this.logoImage.source = this.carrierLogo;
            }
            else{
                this.logoImage.horizontalCenter = 0;
                this.logoImage.source = this.bryantLogo;
            }
            targetUsername = FlexGlobals.topLevelApplication.parameters.username ? (FlexGlobals.topLevelApplication.parameters.username) : ("");
            targetSecret = FlexGlobals.topLevelApplication.parameters.secret ? (FlexGlobals.topLevelApplication.parameters.secret) : ("");
            if (targetUsername && targetSecret){
                MyInfinitySession.instance.addEventListener(MyInfinityEvent.CONNECT, this.sessionConnectHandler);
                MyInfinitySession.instance.addEventListener(MyInfinityEvent.ERROR, this.sessionErrorHandler);
                MyInfinitySession.instance.initWebSession(targetUsername, targetSecret);
            }
            else{
                this.currentState = "default";
                targetPopup = new AlertPopupContainer();
                MyInfinityPopupManager.openPopup(targetPopup, this, true, function () : void {
                targetPopup.titleLabel.text = resourceManager.getString("content", "error2");
                targetPopup.closeButton.label = resourceManager.getString("content", "ok");
                return;
            }            );
            }
            return;
        }
        public function sessionConnectHandler(event:MyInfinityEvent) : void {
            MyInfinitySession.instance.removeEventListener(MyInfinityEvent.CONNECT, this.sessionConnectHandler);
            MyInfinitySession.instance.removeEventListener(MyInfinityEvent.ERROR, this.sessionErrorHandler);
            Model.instance.addEventListener(MyInfinityEvent.COMPLETE, this.modelCompleteHandler);
            Model.instance.addEventListener(MyInfinityEvent.ERROR, this.modelErrorHandler);
            Model.initData();
            return;
        }
        public function sessionErrorHandler(event:MyInfinityEvent) : void {
            var targetPopup:AlertPopupContainer;
            var event:* = event;
            MyInfinitySession.instance.removeEventListener(MyInfinityEvent.CONNECT, this.sessionConnectHandler);
            MyInfinitySession.instance.removeEventListener(MyInfinityEvent.ERROR, this.sessionErrorHandler);
            this.currentState = "default";
            targetPopup = new AlertPopupContainer();
            MyInfinityPopupManager.openPopup(targetPopup, this, true, function () : void {
                targetPopup.titleLabel.text = resourceManager.getString("content", "error1");
                targetPopup.closeButton.label = resourceManager.getString("content", "ok");
                return;
            }            );
            return;
        }
        public function modelCompleteHandler(event:Event) : void {
            Model.instance.removeEventListener(MyInfinityEvent.COMPLETE, this.modelCompleteHandler);
            Model.instance.removeEventListener(MyInfinityEvent.ERROR, this.modelErrorHandler);
            this.navigator.replaceView(HomeView);
            return;
        }
        public function modelErrorHandler(event:Event) : void {
            var targetPopup:AlertPopupContainer;
            var event:* = event;
            Model.instance.removeEventListener(MyInfinityEvent.COMPLETE, this.modelCompleteHandler);
            Model.instance.removeEventListener(MyInfinityEvent.ERROR, this.modelErrorHandler);
            this.currentState = "default";
            targetPopup = new AlertPopupContainer();
            MyInfinityPopupManager.openPopup(targetPopup, this, true, function () : void {
                targetPopup.titleLabel.text = resourceManager.getString("content", "error2");
                targetPopup.closeButton.label = resourceManager.getString("content", "ok");
                return;
            }            );
            return;
        }
        private function _WebLoadingView_MultiDPIBitmapSource2_i() : MultiDPIBitmapSource {
            var _loc_1:* = new MultiDPIBitmapSource();
            _loc_1.source160dpi = this._embed_mxml_res_mdpi_bryantLogo1_png_1361880407;
            _loc_1.source240dpi = this._embed_mxml_res_hdpi_bryantLogo1_png_1227507099;
            _loc_1.source320dpi = this._embed_mxml_res_xhdpi_bryantLogo1_png_282635123;
            this.bryantLogo = _loc_1;
            BindingManager.executeBindings(this, "bryantLogo", this.bryantLogo);
            return _loc_1;
        }
        private function _WebLoadingView_MultiDPIBitmapSource1_i() : MultiDPIBitmapSource {
            var _loc_1:* = new MultiDPIBitmapSource();
            _loc_1.source160dpi = this._embed_mxml_res_mdpi_carrierLogo_png_1764377911;
            _loc_1.source240dpi = this._embed_mxml_res_hdpi_carrierLogo_png_1521018199;
            _loc_1.source320dpi = this._embed_mxml_res_xhdpi_carrierLogo_png_269914967;
            this.carrierLogo = _loc_1;
            BindingManager.executeBindings(this, "carrierLogo", this.carrierLogo);
            return _loc_1;
        }
        private function _WebLoadingView_BasicLayout1_c() : BasicLayout {
            var _loc_1:* = new BasicLayout();
            return _loc_1;
        }
        private function _WebLoadingView_Array2_c() : Array {
            var _loc_1:* = [this._WebLoadingView_BitmapImage1_i()];
            return _loc_1;
        }
        private function _WebLoadingView_BitmapImage1_i() : BitmapImage {
            var _loc_1:* = new BitmapImage();
            _loc_1.verticalCenter = -92;
            _loc_1.initialized(this, "logoImage");
            this.logoImage = _loc_1;
            BindingManager.executeBindings(this, "logoImage", this.logoImage);
            return _loc_1;
        }
        private function _WebLoadingView_BusyIndicatorContainer1_i() : BusyIndicatorContainer {
            var _loc_1:* = new BusyIndicatorContainer();
            _loc_1.width = 80;
            _loc_1.height = 80;
            _loc_1.horizontalCenter = 0;
            _loc_1.verticalCenter = 0;
            _loc_1.id = "_WebLoadingView_BusyIndicatorContainer1";
            if (!_loc_1.document){
                _loc_1.document = this;
            }
            this._WebLoadingView_BusyIndicatorContainer1 = _loc_1;
            BindingManager.executeBindings(this, "_WebLoadingView_BusyIndicatorContainer1", this._WebLoadingView_BusyIndicatorContainer1);
            return _loc_1;
        }
        public function ___WebLoadingView_View1_creationComplete(event:FlexEvent) : void {
            this.creationCompleteHandler(event);
            return;
        }
        override protected function get skinParts() : Object {
            return _skinParts;
        }
        public function get bryantLogo() : MultiDPIBitmapSource {
            return this._1904040425bryantLogo;
        }
        public function set bryantLogo(param1:MultiDPIBitmapSource) : void {
            var _loc_2:* = this._1904040425bryantLogo;
            if (_loc_2 !== param1){
                this._1904040425bryantLogo = param1;
                if (this.hasEventListener("propertyChange")){
                    this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "bryantLogo", _loc_2, param1));
                }
            }
            return;
        }
        public function get carrierLogo() : MultiDPIBitmapSource {
            return this._768156477carrierLogo;
        }
        public function set carrierLogo(param1:MultiDPIBitmapSource) : void {
            var _loc_2:* = this._768156477carrierLogo;
            if (_loc_2 !== param1){
                this._768156477carrierLogo = param1;
                if (this.hasEventListener("propertyChange")){
                    this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "carrierLogo", _loc_2, param1));
                }
            }
            return;
        }
        public function get logoImage() : BitmapImage {
            return this._1580939664logoImage;
        }
        public function set logoImage(param1:BitmapImage) : void {
            var _loc_2:* = this._1580939664logoImage;
            if (_loc_2 !== param1){
                this._1580939664logoImage = param1;
                if (this.hasEventListener("propertyChange")){
                    this.dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, "logoImage", _loc_2, param1));
                }
            }
            return;
        }
    }
}
