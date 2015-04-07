/*
 @author: Igor Savchenko
 Axel Springer ideAS Engineering GmbH
 */

package de.axelspringer.videoplayer.controller
{
    import de.axelspringer.videoplayer.util.Log;

    import flash.display.Sprite;

    import org.osmf.containers.MediaContainer;
    import org.osmf.elements.VideoElement;
    import org.osmf.events.AudioEvent;
    import org.osmf.events.BufferEvent;
    import org.osmf.events.MediaErrorEvent;
    import org.osmf.events.PlayEvent;
    import org.osmf.events.SeekEvent;
    import org.osmf.events.TimeEvent;
    import org.osmf.media.MediaElement;
    import org.osmf.media.MediaPlayer;
    import org.osmf.net.StreamType;
    import org.osmf.net.StreamingURLResource;
    import org.osmf.traits.PlayState;
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

        private function createContainer(mediaElement:MediaElement):void {
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

            var mediaElement:MediaElement = new VideoElement(urlResource);

            /*     var layoutMetadata:LayoutMetadata = new LayoutMetadata();
             layoutMetadata.scaleMode = ScaleMode.ZOOM;
             layoutMetadata.horizontalAlign = HorizontalAlign.CENTER;
             layoutMetadata.verticalAlign = VerticalAlign.MIDDLE;
             mediaElement.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layoutMetadata);*/

            createContainer(mediaElement);

            mediaPlayer.autoPlay = true;
            mediaPlayer.media = mediaElement;

            mediaPlayer.addEventListener(TimeEvent.CURRENT_TIME_CHANGE, onTimeUpdated);
            mediaPlayer.addEventListener(TimeEvent.DURATION_CHANGE, onTimeUpdated);
            mediaPlayer.addEventListener(BufferEvent.BUFFER_TIME_CHANGE, onBufferChange);
            mediaPlayer.addEventListener(SeekEvent.SEEKING_CHANGE, onSeeked);
            mediaPlayer.addEventListener(PlayEvent.PLAY_STATE_CHANGE, onPlayStateChange);
            mediaPlayer.addEventListener(TimeEvent.COMPLETE, onComplete);
            mediaPlayer.addEventListener(AudioEvent.VOLUME_CHANGE, onVolumeChange);
            mediaPlayer.addEventListener(MediaErrorEvent.MEDIA_ERROR, onError);
        }

        public function play():void {
            if (mediaPlayer.paused)
            {
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

        /********************************************************************************************************
         * EXTERNAL EVENTS
         *******************************************************************************************************/

        private function onTimeUpdated(event:TimeEvent):void {
            ExternalController.dispatch(ExternalController.EVENT_TIMEUPDATE, mediaPlayer.currentTime);
        }

        private function onBufferChange(e:BufferEvent):void {
            ExternalController.dispatch(ExternalController.EVENT_PROGRESS, mediaPlayer.bufferLength);
        }

        protected static function onSeeked(e:SeekEvent):void {
            ExternalController.dispatch(ExternalController.EVENT_SEEKED);
        }

        protected static function onPlayStateChange(e:PlayEvent):void {
            if (e.playState == PlayState.PLAYING)
            {
                ExternalController.dispatch(ExternalController.EVENT_PLAYING);
            }
            else if (e.playState == PlayState.PAUSED)
            {
                ExternalController.dispatch(ExternalController.EVENT_PAUSE);
            }
        }

        protected static function onComplete(e:TimeEvent):void {
            ExternalController.dispatch(ExternalController.EVENT_ENDED);
        }

        protected static function onVolumeChange(e:AudioEvent):void {
            ExternalController.dispatch(ExternalController.EVENT_VOLUME_CHANGE);
        }

        protected static function onError(e:MediaErrorEvent):void {
            Log.error("Error:" + e.error.detail + e.error.message);
        }

    }
}