/*
 @author: Igor Savchenko
 Axel Springer ideAS Engineering GmbH
 */

package de.axelspringer.videoplayer.controller
{
    import flash.display.Sprite;

    import org.osmf.containers.MediaContainer;
    import org.osmf.elements.VideoElement;
    import org.osmf.events.MediaErrorEvent;
    import org.osmf.events.MediaPlayerCapabilityChangeEvent;
    import org.osmf.events.MediaPlayerStateChangeEvent;
    import org.osmf.events.TimeEvent;
    import org.osmf.media.MediaElement;
    import org.osmf.media.MediaPlayer;
    import org.osmf.net.StreamType;
    import org.osmf.net.StreamingURLResource;
    import org.osmf.utils.Version;

    /*
    * Player for RTMP Streams using OSMF framework.
     */
    public class OSMFPlayer implements IVideoPlayer
    {
        private var stage:Sprite;

        private var mediaPlayer:MediaPlayer = new MediaPlayer();
        private var container:MediaContainer;

        public function OSMFPlayer(stage:Sprite) {
            trace("OSMF Version", Version.version, Version.buildNumber);

            this.stage = stage;
        }

        private function createContainer (mediaElement:MediaElement):void {
            container = new MediaContainer();
            container.width = this.stage.stage.stageWidth;
            container.height = this.stage.stage.stageHeight;
            container.addMediaElement(mediaElement);

            stage.addChild(container);
        }

        /********************************************************************************************************
         * EXTERNAL CALLBACKS
         *******************************************************************************************************/

        public function loadURL(streamUrl:String):void {
            trace(this + "loadURL: " + streamUrl);

            var urlResource:StreamingURLResource = new StreamingURLResource(streamUrl, StreamType.LIVE_OR_RECORDED);

            var mediaElement:MediaElement = new VideoElement( urlResource );

            /* var layoutMetadata:LayoutMetadata = new LayoutMetadata();
             layoutMetadata.scaleMode = ScaleMode.ZOOM;
             layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
             layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
             mediaElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layoutMetadata);*/

            createContainer (mediaElement);

            mediaPlayer.autoPlay = true;
            mediaPlayer.media = mediaElement;
            trace(">>> can play ", mediaPlayer.canPlay);
            trace(">>> state ", mediaPlayer.state);
            mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onTimeUpdated);
            mediaPlayer.addEventListener(TimeEvent.DURATION_CHANGE, onTimeUpdated);
            mediaPlayer.addEventListener(MediaErrorEvent.MEDIA_ERROR, onError);
            mediaPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE, onCanPlay);
            mediaPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, onChange);
        }


        protected  function onCanPlay(e:MediaPlayerCapabilityChangeEvent):void {
            trace("can play:", e.enabled, mediaPlayer.canPlay);

        }
        protected  function onChange(e:MediaPlayerStateChangeEvent):void {
            trace("state:", e.state, mediaPlayer.state);

        }

        public function play():void {
            if (mediaPlayer.paused) {
                mediaPlayer.play();
            }
        }

        public function volume(value:Number = NaN):Number {
            if (!isNaN(value))
            {
                mediaPlayer.volume = value;
                mediaPlayer.muted = false;
            }

            return mediaPlayer.volume
        }

        public function muted(value:String = ""):Boolean {
            if (value != "")
            {
                mediaPlayer.muted = value == "true";
            }

            return mediaPlayer.muted
        }

        public function pause():void {
            mediaPlayer.pause();
        }

        public function currentTime(seekPoint:Number = NaN):Number {
            if (!isNaN(seekPoint))
            {
                mediaPlayer.seek(seekPoint);
            }
            return mediaPlayer.currentTime;
        }


        public function getDuration():String {
            return mediaPlayer.duration.toString();
        }

        public function getBufferTime():Number {
            return mediaPlayer.bufferTime;
        }

        public function enableHD(value:String = ""):void {
            // nothing here. implementation of interface
        }

        public function destroy():void {
            mediaPlayer.stop();
            stage.removeChild(container);
        }

        /********************************************************************************************************
         * END OF EXTERNAL CALLBACKS
         *******************************************************************************************************/


        protected static function onError(e:MediaErrorEvent):void {
            trace("Error:", e.error.detail, e.error.message);
        }

        private function onTimeUpdated(event:TimeEvent):void {
            trace('time: ' + mediaPlayer.currentTime + ' duration: ' + mediaPlayer.duration + " buffering=" + mediaPlayer.buffering
            + " buffer=" + mediaPlayer.bufferLength);
        }

    }
}