package com.carrier.net
{
    import com.adobe.crypto.*;
    import com.carrier.delegates.*;
    import com.carrier.events.*;
    import flash.events.*;
    import flash.net.*;
    import flash.system.*;

    public class MyInfinitySession extends EventDispatcher {
        public var oauthConsumerKey:String;
        public var oauthConsumerSecret:String;
        public var oauthToken:String = "";
        public var oauthTokenSecret:String = "";
        public var userPassword:String = "";
        public var connected:Boolean = false;
        public static var lastTimestamp:Number;
        static var _instance:MyInfinitySession;
        public static var apiURL:String = "https://www.api.ing.carrier.com";
        public static var forgotPasswordUrl:String = "https://www.myinfinitytouch.carrier.com/Account/ForgotPassword";
        public static const OAUTH_CONSUMER_KEY:String = "dpf43f3p2l4k3l03";
        public static const OAUTH_CONSUMER_SECRET:String = "0t8e47389j37f56u";

        public function MyInfinitySession() {
            return;
        }

        // From embed params, username:secret (WebLoadingView.as:87)
        // (targetUsername, targetSecret) (WebLoadingView.as:92)
        public function initWebSession(param1:String, param2:String) : void {
            Security.loadPolicyFile(apiURL + "/crossdomain.xml");
            if (!param1 || !param2){
                this.dispatchEvent(new MyInfinityEvent(MyInfinityEvent.SESSION_ERROR));
                return;
            }
            this.oauthToken = param1;
            this.oauthTokenSecret = param2;
            this.dispatchEvent(new MyInfinityEvent(MyInfinityEvent.CONNECT));
            return;
        }
        public function initDesktopSession(param1:String, param2:String) : void {
            if (!param1 || !param2){
                this.dispatchEvent(new MyInfinityEvent(MyInfinityEvent.SESSION_ERROR));
            }
            this.oauthToken = param1;
            this.userPassword = param2;
            this.login();
            return;
        }
        protected function login(param1:Boolean = false) : void {
            var _loc_2:* = "<credentials><username><![CDATA[" + this.oauthToken + "]]></username><password><![CDATA[" + this.userPassword + "]]></password></credentials>";
            var _loc_3:* = new XML(_loc_2);
            var _loc_4:* = new URLVariables("data=" + urlEncode(_loc_3.toString()));
            var _loc_5:* = new MyInfinityCall(apiURL + "/users/authenticated", URLRequestMethod.POST, _loc_4);
            _loc_5.addEventListener(MyInfinityEvent.COMPLETE, this.loginCompleteHandler);
            _loc_5.addEventListener(MyInfinityEvent.ERROR, this.loginErrorHandler);
            _loc_5.isOauth = true;
            this.post(_loc_5);
            return;
        }
        public function logout() : void {
            var _loc_1:* = new MyInfinityCall(apiURL + "/users/authenticated/" + this.oauthToken, URLRequestMethod.DELETE);
            _loc_1.addEventListener(MyInfinityEvent.COMPLETE, this.logoutCompleteHandler);
            _loc_1.addEventListener(MyInfinityEvent.ERROR, this.logoutErrorHandler);
            _loc_1.isOauth = true;
            this.post(_loc_1);
            this.oauthTokenSecret = null;
            return;
        }
        public function refreshSession() : void {
            var _loc_1:* = new MyInfinityCall(apiURL + "/users/" + this.oauthToken, URLRequestMethod.GET);
            _loc_1.addEventListener(MyInfinityEvent.COMPLETE, this.refreshCompleteHandler);
            _loc_1.addEventListener(MyInfinityEvent.ERROR, this.refreshErrorHandler);
            _loc_1.isOauth = true;
            this.post(_loc_1);
            return;
        }
        public function post(param1:MyInfinityCall) : MyInfinityCallDelegate {
            param1.session = this;
            return new MyInfinityCallDelegate(param1, this);
        }
        private function decode(param1:Object) : String {
            var _loc_3:* = null;
            var _loc_2:* = new Array();
            for (_loc_3 in param1){

                _loc_2.push(_loc_3 + "=" + encodeURIComponent(_loc_5[_loc_3].toString()));
            }
            _loc_2.sort();
            return _loc_2.join("&");
        }
        protected function loginCompleteHandler(event:MyInfinityEvent) : void {
            var _loc_2:* = event.target as MyInfinityCall;
            _loc_2.removeEventListener(MyInfinityEvent.COMPLETE, this.loginCompleteHandler);
            _loc_2.removeEventListener(MyInfinityEvent.ERROR, this.loginErrorHandler);
            this.oauthTokenSecret = _loc_2.data.xml.accessToken;
            if (this.oauthTokenSecret){
                this.dispatchEvent(new MyInfinityEvent(MyInfinityEvent.CONNECT));
            }
            else{
                this.dispatchEvent(new MyInfinityEvent(MyInfinityEvent.ERROR, false, false, _loc_2));
            }
            return;
        }
        protected function loginErrorHandler(event:MyInfinityEvent) : void {
            var _loc_2:* = event.target as MyInfinityCall;
            _loc_2.removeEventListener(MyInfinityEvent.COMPLETE, this.loginCompleteHandler);
            _loc_2.removeEventListener(MyInfinityEvent.ERROR, this.loginErrorHandler);
            this.dispatchEvent(new MyInfinityEvent(MyInfinityEvent.ERROR, false, false, _loc_2));
            return;
        }
        protected function logoutCompleteHandler(event:MyInfinityEvent = null) : void {
            var _loc_2:* = event.target as MyInfinityCall;
            _loc_2.removeEventListener(MyInfinityEvent.COMPLETE, this.logoutCompleteHandler);
            _loc_2.removeEventListener(MyInfinityEvent.ERROR, this.logoutErrorHandler);
            return;
        }
        protected function logoutErrorHandler(event:MyInfinityEvent) : void {
            var _loc_2:* = event.target as MyInfinityCall;
            _loc_2.removeEventListener(MyInfinityEvent.COMPLETE, this.logoutCompleteHandler);
            _loc_2.removeEventListener(MyInfinityEvent.ERROR, this.logoutErrorHandler);
            return;
        }
        protected function refreshCompleteHandler(event:MyInfinityEvent) : void {
            var _loc_2:* = event.target as MyInfinityCall;
            _loc_2.removeEventListener(MyInfinityEvent.COMPLETE, this.refreshCompleteHandler);
            _loc_2.removeEventListener(MyInfinityEvent.ERROR, this.refreshErrorHandler);
            dispatchEvent(new MyInfinityEvent(MyInfinityEvent.CONNECT));
            return;
        }
        protected function refreshErrorHandler(event:MyInfinityEvent) : void {
            var _loc_2:* = event.target as MyInfinityCall;
            _loc_2.removeEventListener(MyInfinityEvent.COMPLETE, this.refreshCompleteHandler);
            _loc_2.removeEventListener(MyInfinityEvent.ERROR, this.refreshErrorHandler);
            this.oauthTokenSecret = null;
            dispatchEvent(event);
            return;
        }
        public static function get instance() : MyInfinitySession {
            if (!_instance){
                _instance = new MyInfinitySession;
            }
            return _instance;
        }
        public static function formatOauthCall(param1:MyInfinityCall) : void {
            var _loc_4:* = null;
            var _loc_5:* = null;
            var _loc_2:* = param1.session;
            var _loc_3:* = Math.round(new Date().time / 1000);
            if (_loc_3 <= lastTimestamp){
                _loc_3 = lastTimestamp + 1;
            }
            lastTimestamp = _loc_3;
            param1.oauthData.oauth_timestamp = _loc_3.toString();
            param1.oauthData.oauth_nonce = param1.oauthData.oauth_timestamp + Math.round(Math.random() * 1000);
            param1.oauthData.realm = param1.url;
            param1.oauthData.oauth_consumer_key = OAUTH_CONSUMER_KEY;
            param1.oauthData.oauth_token = instance.oauthToken;
            param1.oauthData.oauth_version = "1.0";
            param1.oauthData.oauth_signature_method = "HMAC-SHA1";
            param1.oauthData.oauth_signature = MyInfinitySession.generateSignature(param1);
            if (param1.method == URLRequestMethod.GET){
                for (_loc_4 in param1.oauthData){

                    param1.setRequestArgument(_loc_4, _loc_7[_loc_4].toString());
                }
            }
            else{
                _loc_5 = "OAuth realm=\"" + _loc_7.realm + "\",oauth_consumer_key=\"" + MyInfinitySession.OAUTH_CONSUMER_KEY + "\",oauth_nonce=\"" + _loc_7.oauth_nonce + "\",oauth_signature=\"" + urlEncode(_loc_7.oauth_signature) + "\",oauth_signature_method=\"HMAC-SHA1\",oauth_timestamp=\"" + _loc_7.oauth_timestamp + "\",oauth_token=\"" + _loc_7.oauth_token + "\",oauth_version=\"" + _loc_7.oauth_version + "\"";
                param1.setRequestHeader("Authorization", _loc_5);
            }
            return;
        }
        public static function generateSignature(param1:MyInfinityCall) : String {
            var _loc_4:* = null;
            var _loc_5:* = null;
            var _loc_6:* = null;
            var _loc_2:* = param1.session;
            var _loc_3:* = [];
            for (_loc_4 in param1.oauthData){

                if (_loc_4 != "realm"){
                    _loc_3.push(_loc_4 + "=" + urlEncode(_loc_11[_loc_4].toString()));
                }
            }
            for (_loc_4 in param1.args){

                _loc_3.push(_loc_4 + "=" + urlEncode(_loc_11[_loc_4].toString()));
            }
            _loc_3.sort();
            _loc_5 = urlEncode(_loc_3.join("&"));
            _loc_6 = param1.method;
            if (_loc_6 != URLRequestMethod.GET){
                _loc_6 = URLRequestMethod.POST;
            }
            var _loc_7:* = urlEncode(_loc_6) + "&" + urlEncode(param1.url) + "&" + _loc_5;
            var _loc_8:* = urlEncode(MyInfinitySession.OAUTH_CONSUMER_SECRET) + "&" + urlEncode(_loc_2.oauthTokenSecret);
            var _loc_9:* = HMAC.hash64(_loc_8, _loc_7, SHA1);
            return HMAC.hash64(_loc_8, _loc_7, SHA1);
        }
        public static function urlEncode(param1:String) : String {
            var _loc_2:* = encodeURIComponent(param1);
            var _loc_3:* = /\!/g;
            _loc_2 = _loc_2.replace(_loc_3, "%21");
            _loc_3 = /\*/g;
            _loc_2 = _loc_2.replace(_loc_3, "%2A");
            _loc_3 = /'/g;
            _loc_2 = _loc_2.replace(_loc_3, "%27");
            _loc_3 = /\(/g;
            _loc_2 = _loc_2.replace(_loc_3, "%28");
            _loc_3 = /\)/g;
            _loc_2 = _loc_2.replace(_loc_3, "%29");
            return _loc_2;
        }
    }
}
