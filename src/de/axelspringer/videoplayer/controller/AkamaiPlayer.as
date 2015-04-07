/*
     @author: Igor Savchenko
     Axel Springer ideAS Engineering GmbH
 */
package de.axelspringer.videoplayer.controller
{
    import com.akamai.net.AkamaiConnection;
    import com.akamai.net.AkamaiDynamicNetStream;

    import de.axelspringer.videoplayer.model.vo.Const;
    import de.axelspringer.videoplayer.util.Log;
    import de.axelspringer.videoplayer.view.PlayerView;

    import flash.display.StageDisplayState;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.NetStatusEvent;
    import flash.media.SoundTransform;
    import flash.utils.setTimeout;

    import org.openvideoplayer.events.OvpError;
    import org.openvideoplayer.events.OvpEvent;

    public class AkamaiPlayer extends EventDispatcher implements IVideoPlayer
    {
        // gui
        protected var playerView:PlayerView;

        // stream
        protected var connection:AkamaiConnection;
        protected var netstream:AkamaiDynamicNetStream;
        protected var soundTransform:SoundTransform = new SoundTransform();

        // data
        protected var streamUrl:String;
        protected var streamServer:String;
        protected var streamName:String;
        protected var streamParameters:String;
        protected var streamAuthentification:String;
        protected var streamFingerprint:String;
        protected var streamSList:String;

        // STATUS
        protected var isConnected:Boolean;
        protected var paused:Boolean; // user pause video
        protected var videoBufferEmptyStatus:Boolean;
        protected var videoBufferFlushStatus:Boolean;
        private   var duration:Number = 0;
        protected var doRewind:Boolean = false;
        protected var errorOccured:Boolean = false;
        private var lastVolumeValue:Number = 0;


        public static const AKAMAI_PLAYER_ERROR:String = "AKAMAI_PLAYER_ERROR";

        public function AkamaiPlayer(playerView:PlayerView) {
            this.playerView = playerView;

            this.connection = new AkamaiConnection();
            this.connection.addEventListener(NetStatusEvent.NET_STATUS, onConnectionStatus, false, 0, true);
            this.connection.addEventListener(OvpEvent.ERROR, onError, false, 0, true);
            this.connection.requestedPort = "any";
            this.connection.requestedProtocol = "rtmpe,rtmpte";
        }

        /********************************************************************************************************
         * EXTERNAL CALLBACKS
         *******************************************************************************************************/

        public function loadURL(streamUrl:String):void {
            trace(this + "loadURL: " + streamUrl);

            this.resetStatus();

            this.streamUrl = streamUrl;
            this.parseStreamUrl(this.streamUrl);
        }

        public function play():void {

            if (this.paused)
            {
                resume();
            }
            else if (!this.isConnected)
            {
                trace(this + " play");
                trace(this + " ---> server: " + this.streamServer);
                trace(this + " ---> parameters: " + this.streamParameters);

                this.paused = false;

                if (this.streamParameters != "")
                {
                    this.connection.connectionAuth = this.streamParameters;
                }
                this.connection.connect(this.streamServer);
                isConnected = true;
            }
        }

        public function volume(value:Number = NaN):Number {
            if (!isNaN(value))
            {
                lastVolumeValue = soundTransform.volume;
                this.soundTransform.volume = value;

                if (this.netstream != null)
                {
                    this.netstream.soundTransform = this.soundTransform;
                    ExternalController.dispatch(ExternalController.EVENT_VOLUME_CHANGE);
                }
            }

            return this.soundTransform ? this.soundTransform.volume : 0
        }

        // TODO: test muted stream
        public function muted(value:String = ""):Boolean {
            if (value != "")
            {
                var muteValue:Number = value == "false" ? lastVolumeValue : 0;
                volume(muteValue);
            }

            return this.soundTransform.volume == 0
        }

        public function pause():void {
            this.paused = true;

            if (this.isConnected)
            {
                this.netstream.pause();
            }
        }

        public function currentTime(seekPoint:Number  = NaN):Number {

            if (this.netstream != null && !isNaN(seekPoint))
            {
                Log.info(this + "seek to the point: " + seekPoint);
                ExternalController.dispatch(ExternalController.EVENT_WAITING, true);

                // set lower buffer time to enable fast video start after seeking
                this.netstream.bufferTime = Const.buffertimeMinimum;

                this.netstream.seek(seekPoint);
            }

            return this.netstream ? this.netstream.time : 0;
        }

        public function getDuration():String {
            return duration == 0 ? "Infinity" : duration.toString();
        }

        public function getBufferTime():Number {
            return this.netstream ? this.netstream.time + this.netstream.bufferTime : 0;
        }

        public function enableHD(value:String = ""):void {
            // nothing here. implementation of interface
        }

        public function destroy():void
        {
            if (this.playerView.display) {
                this.playerView.display.removeEventListener(Event.ENTER_FRAME, onVideoEnterFrame);
            }
            this.playerView.clearView();

            isConnected = false;

            Log.info("Netstream von Akamai wird gestoppt.");

            if (netstream)
            {
                this.netstream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStreamStatus);
                this.netstream.removeEventListener(OvpEvent.ERROR, onError);
                this.netstream.removeEventListener(OvpEvent.COMPLETE, onStreamFinished);
                this.netstream.removeEventListener(OvpEvent.NETSTREAM_METADATA, onMetaData);
                this.netstream.close();
                this.netstream = null;
            }

            /*if (connection)
            {
                this.connection.removeEventListener(NetStatusEvent.NET_STATUS, onConnectionStatus);
                this.connection.removeEventListener(OvpEvent.ERROR, onError);
                this.connection.close();
                this.connection = null;
            }*/
        }

        /********************************************************************************************************
         * END OF EXTERNAL CALLBACKS
         *******************************************************************************************************/

        private function resume():void {
            this.paused = false;

            // set lower buffer here to enable fast video start after pause
            this.netstream.bufferTime = Const.buffertimeMinimum;

            trace(this + " set buffertime to " + this.netstream.bufferTime);

            this.netstream.resume();
        }

        /**
         * rewinds the stream first and then updates the display with the first frame
         */
        protected function rewindStream(toPosition:Number):void {
            trace(this + " rewindStream to " + toPosition);

            // re-attach netstream
            this.playerView.display.attachNetStream(null);
            this.playerView.display.attachNetStream(this.netstream);

            this.netstream.seek(toPosition);
            this.netstream.resume();
        }

        protected function onConnectionStatus(e:NetStatusEvent):void {
            trace(this + " onConnectionStatus: " + e.info.code);

            switch (e.info.code)
            {
                case "NetConnection.Connect.Success":
                {
                    this.onConnectionConnect();

                    break;
                }
                case "NetConnection.Connect.Rejected":
                case "NetConnection.Connect.Refused":
                case "NetConnection.Connect.Failed":
                case "NetConnection.Connect.Closed":
                {
                    this.treatError(e.info.code, e.info.description);
                    break;
                }
            }
        }

        protected function onConnectionConnect():void {
            trace(this + " onConnectionConnect");

            this.netstream = new AkamaiDynamicNetStream(this.connection);
            this.netstream.bufferTime = Const.buffertimeMinimum;

            trace(this + " set buffertime to " + this.netstream.bufferTime);

            this.netstream.addEventListener(NetStatusEvent.NET_STATUS, onNetStreamStatus, false, 0, true);
            this.netstream.addEventListener(OvpEvent.ERROR, onError, false, 0, true);
            this.netstream.addEventListener(OvpEvent.COMPLETE, onStreamFinished, false, 0, true);
            this.netstream.addEventListener(OvpEvent.NETSTREAM_METADATA, onMetaData, false, 0, true);
            this.netstream.createProgressivePauseEvents = true;

            // initializing?
            this.netstream.soundTransform = this.soundTransform;

            this.playerView.display.attachNetStream(null);
            this.playerView.display.attachNetStream(this.netstream);

            ExternalController.dispatch(ExternalController.EVENT_WAITING, true);
            this.netstream.play(this.streamName, 0);
        }

        protected function onMetaData(e:OvpEvent):void
        {
            ExternalController.dispatch(ExternalController.EVENT_LOADED_METADATA, e.data);

            // check ratio
            var ratio:Number = 16 / 9;

            if (e.data.width != null && e.data.height != null)
            {
                ratio = parseFloat(e.data.width) / parseFloat(e.data.height);
            }

            this.playerView.setVideoRatio(ratio);

            // check duration
            if (e.data.duration != null)
            {
                this.duration = Number(e.data.duration);
            }
        }

        protected function onNetStreamStatus(e:NetStatusEvent):void {
            trace(this + " onNetStreamStatus: " + e.info.code);

            switch (e.info.code)
            {
                case "NetStream.Buffer.Flush":
                {
                    this.videoBufferFlushStatus = true;
                    break;
                }
                case "NetStream.Seek.Notify":
                {
                    this.videoBufferEmptyStatus = false;

                    // set lower buffer here to enable fast video start after pause
                    this.netstream.bufferTime = Const.buffertimeMinimum;

                    trace(this + " set buffertime to " + this.netstream.bufferTime);
                    ExternalController.dispatch(ExternalController.EVENT_SEEKED);

                    break;
                }
                case "NetStream.Buffer.Full":
                {
                    this.videoBufferEmptyStatus = false;

                    ExternalController.dispatch(ExternalController.EVENT_WAITING, false);

                    // set higher buffer now to enable constant playback
                    this.netstream.bufferTime = Const.buffertimeMaximum;

                    trace(this + " set buffertime to " + this.netstream.bufferTime);

                    break;
                }
                case "NetStream.Buffer.Empty":
                {
                    this.videoBufferEmptyStatus = true;
                    if (!this.videoBufferFlushStatus)
                    {
                        ExternalController.dispatch(ExternalController.EVENT_WAITING, true);

                        // set lower buffer here to enable fast video start
                        this.netstream.bufferTime = Const.buffertimeMinimum;

                        trace(this + " set buffertime to " + this.netstream.bufferTime);
                    }

                    ExternalController.dispatch(ExternalController.EVENT_EMPTIED);

                    break;
                }
                case "NetStream.Play.Start":
                {
                    this.onStreamStarted();
                    ExternalController.dispatch(ExternalController.EVENT_WAITING, false);

                    break;
                }
                case "NetStream.Play.Stop":
                {
                    break;
                }
                case "NetStream.Failed":
                case "NetStream.Play.StreamNotFound":
                case "NetStream.Play.Failed":
                {
                    this.treatError(e.info.code, e.info.description);
                    break;
                }
            }

            // if stopped, check buffer stati for OnDemandStreams
            // for LiveStreams, this is the end
            if (this.videoBufferEmptyStatus == true && this.videoBufferFlushStatus == true && !this.paused)
            {
                this.onStreamFinished();
            }
        }

        protected function onVideoEnterFrame(e:Event):void {
            if (this.paused || !this.netstream)
            {
                return;
            }

            ExternalController.dispatch(ExternalController.EVENT_TIMEUPDATE, this.netstream.time);

            if (this.duration > 0)
            {
                var progress:Number = this.netstream.bytesLoaded / this.netstream.bytesTotal;
                ExternalController.dispatch(ExternalController.EVENT_PROGRESS, progress);
            }
        }

        protected function onStreamStarted():void {
            // for refreshing the display after the rewind, stream should start in pause mode and then stop
            if (this.paused)
            {
                setTimeout(this.netstream.pause, 200);

                // if teaser, rewind now
                if (this.doRewind)
                {
                    this.doRewind = false;
                    setTimeout(this.netstream.seek, 300, 0);
                }

                return;
            }

            this.resetStatus();
            this.isConnected = true;

            if (!this.playerView.display.hasEventListener(Event.ENTER_FRAME))
            {
                this.playerView.display.addEventListener(Event.ENTER_FRAME, onVideoEnterFrame, false, 0, true);
            }

            ExternalController.dispatch(ExternalController.EVENT_PLAYING);
        }

        protected function onStreamFinished(e:Event = null):void {
            trace(this + " onStreamFinished");
            // minimize in case of fullscreen
            if (this.playerView.display.stage.displayState == StageDisplayState.FULL_SCREEN)
            {
                this.playerView.display.stage.dispatchEvent(new Event(Event.RESIZE));
            }

            this.rewindStream(0);

            this.playerView.display.removeEventListener(Event.ENTER_FRAME, onVideoEnterFrame);

            this.pause();

            if (!this.errorOccured)
            {
                ExternalController.dispatch(ExternalController.EVENT_ENDED);
            }
        }

        protected function resetStatus():void {
            this.isConnected = false;
            this.videoBufferEmptyStatus = false;
            this.videoBufferFlushStatus = false;
            this.paused = false;
            this.errorOccured = false;
        }

        protected function onError(e:OvpEvent):void
        {
            treatError(OvpError(e.data).errorDescription);
        }

        protected function treatError(code:String, description:String = ""):void {
            Log.warn(this + "Error: " + code + ", description: " + description);

            dispatchEvent(new Event(AKAMAI_PLAYER_ERROR));

            this.errorOccured = true;
            destroy();
        }

        protected function parseStreamUrl(url:String):void {

            var index:Number = url.indexOf("://");
            url = url.substring(index + 3);
            // WTF? this means only urls with more than one "/" allowed here, like http://xxx/xxx/xxxx and not httpd://xxx/xxx
            index = url.indexOf("/", url.indexOf("/") + 1);

            this.streamServer = url.substring(0, index);

            var file:String = url.substring(index + 1);

            // default values without authentification - if authentifications is used they will be overwritten
            this.streamName = file;
            this.streamParameters = "";
            this.streamAuthentification = "";
            this.streamFingerprint = "";
            this.streamSList = "";

            index = file.indexOf("?");

            if (index > -1)
            {
                this.streamName = file.substring(0, index);
                this.streamParameters = file.substring(index + 1);
                var paramArray:Array = this.streamParameters.split("&");
                var param:String;

                for (var i:uint = 0; i < paramArray.length; i++)
                {
                    param = paramArray[i];
                    if (param.substring(0, 5) == "auth=")
                    {
                        this.streamAuthentification = param.substring(5);
                    }
                    if (param.substring(0, 5) == "aifp=")
                    {
                        this.streamFingerprint = param.substring(5);
                    }
                    if (param.substring(0, 6) == "slist=")
                    {
                        this.streamSList = param.substring(6);
                    }
                }
            }

            if (this.streamParameters != "")
            {
                this.streamName = this.streamName + "?" + this.streamParameters;
            }
        }

    }
}