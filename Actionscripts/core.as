package {
	import flash.display.Sprite;
	[SWF(width="640", height="480", framerate="30", backgroundColor="#ffffff")]
	public class ARProj extends Sprite
	{
		// Embed the marker.pat file 
		[Embed(source="marker.pat", mimeType="application/octet-stream")]
		private var marker:Class;
		
		// Embed the camera.pat file
		[Embed(source="camera_para.dat", mimeType="application/octet-stream")]
		private var cam_params:Class;
		
		// createFLAR Vars
		private var ar_params:FLARParam;
		private var ar_marker:FLARCode;
		
		// createCAM Vars
		private var ar_vid:Video;
		private var ar_cam:Camera;
		
		// createBMP Vars
		private var ar_bmp:BitmapData;
		private var ar_raster:FLARRgbRaster_BitmapData;
		private var ar_detection:FLARSingleMarkerDetector;
		
		// createPapervision Vars
		private var ar_scene:Scene3D;
		private var	ar_3dcam:FLARCamera3D;
		private var	ar_basenode:FLARBaseNode;
		private var	ar_viewport:Viewport3D;
		private var	ar_renderengine:BasicRenderEngine;
		private var	ar_transmat:FLARTransMatResult;
		private var	ar_cube:Cube;

		public function ARProj()
		{
			createFLAR();
			createCAM();
			createBMP();
			createPapervision();
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		public function createFLAR()
		{
				ar_params = new FLARParam();
				ar_marker = new FLARCode();
				ar_params.loadParam(new cam_params() as ByteArray);
				ar_marker.loadARPatt(new marker());
		}
		
		public function createCAM()
		{
				ar_vid = new Video(640, 480);
				ar_cam = Camera.getCamera();
				ar_cam.setMode(640,480,30);
				ar_vid.attachCamera(ar_cam);
				addChild(ar_vid);
		}
		
		public function createBMP()
		{
				ar_bmp = new BitmapData(640,480);
				ar_bmp.draw(ar_vid);
				ar_raster = new FLARRgbRaster_BitmapData(ar_bmp);
				ar_raster = new FLARSingleMarkerDetector(ar_params, ar_marker, 80);	
		}
		public function createPapervision()
		{
				ar_scene = new Scene3D();
				ar_3dcam = new FLARCamera3D(ar_params); 
				ar_basenode = new FLARBaseNode();
				ar_renderengine = new BasicRenderEngine();
				ar_transmat = new FLARTransMatResult();
				ar_viewport = new Viewport3D();
				
				var ar_light:PointLight3D = new PointLight3D();
				ar_light.x = 1000;
				ar_light.y = 1000;
				ar_light.z = -1000;
				
				var ar_bitmap:BitmapMaterial;
				ar_bitmap = new BitmapFileMaterial("image.jpeg");
				ar_bitmap.doubleSided = true; 
				
				ar_cube = new MaterialsList({all:ar_bitmap}), 80, 80, 80);
				ar_scene.addChild(ar_baseNnode);
				ar_basenode.addChild(ar_cube);
				addChild(ar_viewport);	
		}	
		public function loop(e:Event):void
		{
				ar_bmp.draw(ar_vid);
				ar_cube.rotationX +=4;
				ar_cube.rotationY +=6;
				
				try
				{
					if (ar_detection.detectMarkerLite(ar_raster, 80) && ar_detection.getConfidence() > 0)
					{
						ar_detection.getTransformMatrix(ar_transmat);
						ar_basenode.setTransformMatrix(ar_transmat);
						ar_renderengine.renderScene(ar_scene, ar_3dcam, ar_viewport);
					}	
				}
				catch(e:Error){}
		}
	}
}
