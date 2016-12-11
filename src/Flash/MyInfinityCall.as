package com.carrier.net
{
    import com.carrier.data.*;
    import com.carrier.delegates.*;
    import com.carrier.errors.*;
    import com.carrier.events.*;
    import flash.events.*;
    import flash.net.*;

    public class MyInfinityCall extends EventDispatcher {
        public var url:String;
        public var method:String;
        public var headers:Array;
        public var args:URLVariables;
        public var oauthData:Object;
        public var isOauth:Boolean = true;
        public var HTTPStatus:int;
        public var timestamp:Date;
        public var data:MyInfinityData;
        public var error:MyInfinityErrorData;
        public var delegate:IMyInfinityCallDelegate;
        public var session:MyInfinitySession;
        public var success:Boolean = false;
        public var etag:String = "";

        public function MyInfinityCall(param1:String, param2:String = "GET", param3:URLVariables = null) {
            this.oauthData = {};
            this.url = param1;
            this.method = param2;
            this.args = param3 ? (param3) : (new URLVariables());
            this.headers = new Array();
            return;
        }
        public function setRequestHeader(param1:String, param2:Object) : void {
            var _loc_3:* = null;
            var _loc_4:* = null;
            for (_loc_3 in this.headers){
                
                _loc_4 = _loc_6[_loc_3] as URLRequestHeader;
                if (_loc_4.name == param1){
                    _loc_4.value = param2.toString();
                    return;
                }
            }
            _loc_6.push(new URLRequestHeader(param1, param2.toString()));
            return;
        }
        public function setRequestArgument(param1:String, param2:Object) : void {
            if (param2 is Number && isNaN(param2 as Number)){
                return;
            }
            if (param1 && param2 != null && String(param2).length > 0){
                this.args[param1] = param2;
            }
            return;
        }
        public function clearRequestArguments() : void {
            this.args = new URLVariables();
            return;
        }
        public function clearRequestHeaders() : void {
            this.headers = new Array();
            return;
        }
        public function handleResult(param1:MyInfinityData) : void {
            this.data = param1;
            this.data.responseTimestamp = this.timestamp;
            this.success = true;
            dispatchEvent(new MyInfinityEvent(MyInfinityEvent.COMPLETE));
            return;
        }
        public function handleError(param1:MyInfinityErrorData) : void {
            this.error = param1;
            this.success = false;
            dispatchEvent(new MyInfinityEvent(MyInfinityEvent.ERROR, false, false, this));
            return;
        }
    }
}
