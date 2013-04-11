package
{
	import com.adobe.images.PNGEncoder;
	import com.bit101.components.ProgressBar;
	import com.bit101.components.PushButton;
	import com.bit101.components.Style;
	import com.ybcx.animdiy.common.Toast;
	
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	
	/**
	 * 一个swf动画抓帧工具，为所有的帧生成原比例大小的png图片；
	 * 
	 * @author lwz7512@gmail.com
	 * 2013/04/11
	 */
	[SWF(width="500", height="400", backgroundColor="0xFFFFFF", frameRate="12")]
	public class Main extends BaseApp{
		
		private var _fileRef:File;
		private var _filters:Array;
		private var _swfLoader:Loader;
		
		private var _movie:MovieClip;
		
		private var _recordComplete:Boolean;
		
		private var _progress:ProgressBar;
		
		private var _savePngDirectory:String;
		
		private var _shots:Array;
		private var _shotIndex:int;
		
		private var _fastCreatePngTimer:Timer;
		
		
		public function Main(){
			_fastCreatePngTimer = new Timer(10);
			_fastCreatePngTimer.addEventListener(TimerEvent.TIMER, onTimer);
		}
		
		override protected function buildApp(evt:Event):void{			
			super.buildApp(evt);
			
			_swfLoader = new Loader();
			_swfLoader.x = 10;
			_swfLoader.y = 30;
			_swfLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onMovieLoad);
			this.addChild(_swfLoader);

			_fileRef = new File();
			_fileRef.addEventListener(Event.SELECT, onFileSelect);
			
			_filters = [];
			var swfTypeFilter:FileFilter = new FileFilter("SWF Files (*.swf)","*.swf");
			var allTypeFilter:FileFilter = new FileFilter("All Files (*.*)","*.*");
			_filters.push(swfTypeFilter);
			_filters.push(allTypeFilter);
			
			var open:PushButton = new PushButton(this, 0,0, "打开本地SWF");
			open.addEventListener(MouseEvent.CLICK, onBtnClick);
			
			var record:PushButton = new PushButton(this, 120, 0, "录屏");
			record.addEventListener(MouseEvent.CLICK, onRecordClick);
			
			var save:PushButton = new PushButton(this, 240, 0, "输出为PNG");
			save.addEventListener(MouseEvent.CLICK, onPNGoutput);
			
			Style.PROGRESS_BAR = 0x00BC12;
			_progress = new ProgressBar(this, 360, 0);
			_progress.setSize(100, 19);
			
			
			this.showMessage("先打开本地swf模版文件...",true);
		}
		
		private function onPNGoutput(evt:MouseEvent):void{
			if(!_recordComplete) return;
			if(!_movie) return;	
			if(_fastCreatePngTimer.running) return;
			
			_fastCreatePngTimer.start();//开始生成文件
			_shotIndex = 0;
		}
		
		private function onTimer(evt:TimerEvent):void{
			
			if(_shotIndex==_shots.length){
				_fastCreatePngTimer.stop();
				this.showMessage("文件输出完成："+_savePngDirectory, true);
				return;
			}
			
			var pngFile:File = new File(_savePngDirectory+"\\"+_shotIndex+".png");
			createPngFile(pngFile, _shots[_shotIndex]);
			
			_progress.value = _shotIndex/_shots.length;
			
			_shotIndex ++;
		}
		
		private function createPngFile(fl:File, imgByteArray:ByteArray):void{
			if(!imgByteArray || !imgByteArray.bytesAvailable) return;
			
			var fs:FileStream = new FileStream();
			var before:Number = (new Date()).time;//先积累当前时间
			try{
				//open file in write mode
				fs.open(fl,FileMode.WRITE);
				//write bytes from the byte array
				fs.writeBytes(imgByteArray);
				//close the file
				fs.close();				
			}catch(e:Error){
				trace(e.message);
				this.showMessage("Create png Error!");
			}
		}
		
		private function onRecordClick(evt:MouseEvent):void{
			if(_recordComplete) return;
			if(!_movie) return;	
			
			this.addEventListener(Event.ENTER_FRAME, recording);
			_movie.play();
		}
		
		private function recording(evt:Event):void{			
			
			if(_movie.currentFrame==_movie.totalFrames){
				stopRecord();
			}
			
			if(_movie.currentFrame % 2) return;
						
			_progress.value = _movie.currentFrame/_movie.totalFrames;						
			
			//RECOARDING SCREEN...
			var eachFrame:ByteArray = snapFrame();
			if(eachFrame) _shots.push(eachFrame);
						
		}
		
		private function stopRecord():void{
			this.removeEventListener(Event.ENTER_FRAME, recording);
			this.showMessage("录屏完成，可以输出为png图片了！", true);
			_movie.stop();
			_recordComplete = true;
			trace("record completed!");
		}
		
		/**
		 * 抓取当前动画帧
		 */ 
		private function snapFrame():ByteArray{
			var before:Number = (new Date()).time;//先积累当前时间		
			
			var bd:BitmapData = new BitmapData(480,360);			
			bd.draw(_movie);
			
			var bytes:ByteArray = PNGEncoder.encode(bd);
			bytes.position = 0;
			bd.dispose();
			
			var consume:int= (new Date()).time - before;//积累录屏后时间
//			trace("shot size/consume time: "+int(bytes.length/1024) +"k/"+ consume +"ms");
			
			return bytes;
		}

		
		private function onMovieLoad(evt:Event):void{
			_movie = _swfLoader.content as MovieClip;			
			_movie.addEventListener(Event.ENTER_FRAME, onMovieAdded);
			
			var totalFrames:int = _movie.totalFrames;
			trace("swf total frames: "+totalFrames);
			
			_recordComplete = false;
			
			this.showMessage("可以录屏了！",true);
		}
		
		private function onMovieAdded(evt:Event):void{
			_movie.removeEventListener(Event.ENTER_FRAME, onMovieAdded);
			_movie.stop();
		}
		
		private function onBtnClick(evt:MouseEvent):void{
			_fileRef.browse(_filters);
		}
		
		private function onFileSelect(evt:Event):void{
			_shots = [];
			_movie = null;
			_swfLoader.unloadAndStop();
			
			var filePath:String = _fileRef.nativePath;
			_swfLoader.load(new URLRequest(_fileRef.url));
						
			var tempDir:File = new File(filePath.substring(0, filePath.lastIndexOf("\\"))+"\\pngs");			
			_savePngDirectory = tempDir.nativePath;
			
//			tempDir.addEventListener(IOErrorEvent.IO_ERROR, onFileIO);
//			tempDir.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onFileError);
			if(!tempDir.exists){
				tempDir.createDirectory();
			}
		}
		
		private function onFileIO(evt:IOErrorEvent):void{
			trace("io error event...");
		}
		
		private function onFileError(evt:SecurityErrorEvent):void{
			evt.toString();
		}
		
		public function showMessage(msg:String, long:Boolean=false):void{
			Toast.getInstance(stage).show(msg, stage.stageWidth/2, stage.stageHeight/2, long);
		}
		
	} //end of class...
} //end of package