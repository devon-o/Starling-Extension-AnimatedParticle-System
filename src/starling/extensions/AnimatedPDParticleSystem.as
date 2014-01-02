// =================================================================================================
//
//	Starling Framework - Particle System Extension
//	Copyright 2012 Gamua OG. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//  
//  Modified for animation by Devon O. Wolfgang 2013
// =================================================================================================

package starling.extensions
{
    import flash.display3D.Context3DBlendFactor;
    import flash.geom.Rectangle;
    import starling.events.Event;
    import starling.textures.TextureAtlas;
    
    import starling.textures.Texture;
    import starling.utils.deg2rad;
    
    public class AnimatedPDParticleSystem extends OpenParticleSystem
    {
        private const EMITTER_TYPE_GRAVITY:int = 0;
        private const EMITTER_TYPE_RADIAL:int  = 1;
        
        // emitter configuration                            // .pex element name
        private var mEmitterType:int;                       // emitterType
        private var mEmitterXVariance:Number;               // sourcePositionVariance x
        private var mEmitterYVariance:Number;               // sourcePositionVariance y
        
        // particle configuration
        private var mMaxNumParticles:int;                   // maxParticles
        private var mLifespan:Number;                       // particleLifeSpan
        private var mLifespanVariance:Number;               // particleLifeSpanVariance
        private var mStartSize:Number;                      // startParticleSize
        private var mStartSizeVariance:Number;              // startParticleSizeVariance
        private var mEndSize:Number;                        // finishParticleSize
        private var mEndSizeVariance:Number;                // finishParticleSizeVariance
        private var mEmitAngle:Number;                      // angle
        private var mEmitAngleVariance:Number;              // angleVariance
        private var mStartRotation:Number;                  // rotationStart
        private var mStartRotationVariance:Number;          // rotationStartVariance
        private var mEndRotation:Number;                    // rotationEnd
        private var mEndRotationVariance:Number;            // rotationEndVariance
        
        // gravity configuration
        private var mSpeed:Number;                          // speed
        private var mSpeedVariance:Number;                  // speedVariance
        private var mGravityX:Number;                       // gravity x
        private var mGravityY:Number;                       // gravity y
        private var mRadialAcceleration:Number;             // radialAcceleration
        private var mRadialAccelerationVariance:Number;     // radialAccelerationVariance
        private var mTangentialAcceleration:Number;         // tangentialAcceleration
        private var mTangentialAccelerationVariance:Number; // tangentialAccelerationVariance
        
        // radial configuration 
        private var mMaxRadius:Number;                      // maxRadius
        private var mMaxRadiusVariance:Number;              // maxRadiusVariance
        private var mMinRadius:Number;                      // minRadius
        private var mRotatePerSecond:Number;                // rotatePerSecond
        private var mRotatePerSecondVariance:Number;        // rotatePerSecondVariance
        
        // color configuration
        private var mStartColor:ColorArgb;                  // startColor
        private var mStartColorVariance:ColorArgb;          // startColorVariance
        private var mEndColor:ColorArgb;                    // finishColor
        private var mEndColorVariance:ColorArgb;            // finishColorVariance
        
        // animated texture settings
        private var atlas:TextureAtlas;
        private var fps:int;
        private var startFrame:int;
        private var animationPrefix:String;
        
        /**
         * Creates an AnimatedPDParticleSystem
         * @param config            particle configuration file (XML from .pex file)
         * @param atlas             TextureAtlas containing animation
         * @param fps               Desired frames per second
         * @param startFrame        Frame animation should begin on. First frame is 0. Passing -1 will start animation on random frame
         * @param animationPrefix   Name of animation in Atlas. An empty String will use the entire atlas.
         */
        public function AnimatedPDParticleSystem(config:XML, atlas:TextureAtlas, fps:int=12, startFrame:int=-1, animationPrefix:String="")
        {
            parseConfig(config);
            
            this.atlas = atlas;
            this.fps = fps;
            this.startFrame = startFrame;
            this.animationPrefix = animationPrefix;
            
            var emissionRate:Number = mMaxNumParticles / mLifespan;
            super(this.atlas.texture, emissionRate, mMaxNumParticles, mMaxNumParticles,
                  mBlendFactorSource, mBlendFactorDestination);
            
            mPremultipliedAlpha = false;
        }
        
        /**
         * Dispose (including the particle TextureAtlas).
         */
        public function disposeWithAtlas():void
        {
            this.atlas.dispose();
            super.dispose();
        }
        
        protected override function createParticle():Particle
        {
            var p:AnimatedPDParticle = new AnimatedPDParticle(this.atlas, this.fps, this.animationPrefix);
            p.startFrame = this.startFrame;
            return p;
        }
        
        protected override function initParticle(aParticle:Particle):void
        {
            var particle:PDParticle = aParticle as PDParticle; 
         
            // for performance reasons, the random variances are calculated inline instead
            // of calling a function
            
            var lifespan:Number = mLifespan + mLifespanVariance * (Math.random() * 2.0 - 1.0);
            
            particle.currentTime = 0.0;
            particle.totalTime = lifespan > 0.0 ? lifespan : 0.0;
            
            if (lifespan <= 0.0) return;
            
            particle.x = mEmitterX + mEmitterXVariance * (Math.random() * 2.0 - 1.0);
            particle.y = mEmitterY + mEmitterYVariance * (Math.random() * 2.0 - 1.0);
            particle.startX = mEmitterX;
            particle.startY = mEmitterY;
            
            var angle:Number = mEmitAngle + mEmitAngleVariance * (Math.random() * 2.0 - 1.0);
            var speed:Number = mSpeed + mSpeedVariance * (Math.random() * 2.0 - 1.0);
            particle.velocityX = speed * Math.cos(angle);
            particle.velocityY = speed * Math.sin(angle);
            
            particle.emitRadius = mMaxRadius + mMaxRadiusVariance * (Math.random() * 2.0 - 1.0);
            particle.emitRadiusDelta = mMaxRadius / lifespan;
            particle.emitRotation = mEmitAngle + mEmitAngleVariance * (Math.random() * 2.0 - 1.0); 
            particle.emitRotationDelta = mRotatePerSecond + mRotatePerSecondVariance * (Math.random() * 2.0 - 1.0); 
            particle.radialAcceleration = mRadialAcceleration + mRadialAccelerationVariance * (Math.random() * 2.0 - 1.0);
            particle.tangentialAcceleration = mTangentialAcceleration + mTangentialAccelerationVariance * (Math.random() * 2.0 - 1.0);
            
            var startSize:Number = mStartSize + mStartSizeVariance * (Math.random() * 2.0 - 1.0); 
            var endSize:Number = mEndSize + mEndSizeVariance * (Math.random() * 2.0 - 1.0);
            if (startSize < 0.1) startSize = 0.1;
            if (endSize < 0.1)   endSize = 0.1;
            particle.scale = startSize / texture.width;
            particle.scaleDelta = ((endSize - startSize) / lifespan) / texture.width;
            
            // colors
            
            var startColor:ColorArgb = particle.colorArgb;
            var colorDelta:ColorArgb = particle.colorArgbDelta;
            
            startColor.red   = mStartColor.red;
            startColor.green = mStartColor.green;
            startColor.blue  = mStartColor.blue;
            startColor.alpha = mStartColor.alpha;
            
            if (mStartColorVariance.red != 0)   startColor.red   += mStartColorVariance.red   * (Math.random() * 2.0 - 1.0);
            if (mStartColorVariance.green != 0) startColor.green += mStartColorVariance.green * (Math.random() * 2.0 - 1.0);
            if (mStartColorVariance.blue != 0)  startColor.blue  += mStartColorVariance.blue  * (Math.random() * 2.0 - 1.0);
            if (mStartColorVariance.alpha != 0) startColor.alpha += mStartColorVariance.alpha * (Math.random() * 2.0 - 1.0);
            
            var endColorRed:Number   = mEndColor.red;
            var endColorGreen:Number = mEndColor.green;
            var endColorBlue:Number  = mEndColor.blue;
            var endColorAlpha:Number = mEndColor.alpha;

            if (mEndColorVariance.red != 0)   endColorRed   += mEndColorVariance.red   * (Math.random() * 2.0 - 1.0);
            if (mEndColorVariance.green != 0) endColorGreen += mEndColorVariance.green * (Math.random() * 2.0 - 1.0);
            if (mEndColorVariance.blue != 0)  endColorBlue  += mEndColorVariance.blue  * (Math.random() * 2.0 - 1.0);
            if (mEndColorVariance.alpha != 0) endColorAlpha += mEndColorVariance.alpha * (Math.random() * 2.0 - 1.0);
            
            colorDelta.red   = (endColorRed   - startColor.red)   / lifespan;
            colorDelta.green = (endColorGreen - startColor.green) / lifespan;
            colorDelta.blue  = (endColorBlue  - startColor.blue)  / lifespan;
            colorDelta.alpha = (endColorAlpha - startColor.alpha) / lifespan;
            
            // rotation
            
            var startRotation:Number = mStartRotation + mStartRotationVariance * (Math.random() * 2.0 - 1.0); 
            var endRotation:Number   = mEndRotation   + mEndRotationVariance   * (Math.random() * 2.0 - 1.0);
            
            particle.rotation = startRotation;
            particle.rotationDelta = (endRotation - startRotation) / lifespan;
            
            // Animated Particle
            var ap:AnimatedPDParticle = particle as AnimatedPDParticle;
            if (ap)
            {
                if (ap.startFrame == -1)
                    ap.frameNum = int(Math.random() * ap.regions.length);
                else 
                    ap.frameNum = ap.startFrame;
            }
        }
        
        protected override function advanceParticle(aParticle:Particle, passedTime:Number):void
        {
            var particle:PDParticle = aParticle as PDParticle;
            
            var restTime:Number = particle.totalTime - particle.currentTime;
            passedTime = restTime > passedTime ? passedTime : restTime;
            particle.currentTime += passedTime;
            
            if (mEmitterType == EMITTER_TYPE_RADIAL)
            {
                particle.emitRotation += particle.emitRotationDelta * passedTime;
                particle.emitRadius   -= particle.emitRadiusDelta   * passedTime;
                particle.x = mEmitterX - Math.cos(particle.emitRotation) * particle.emitRadius;
                particle.y = mEmitterY - Math.sin(particle.emitRotation) * particle.emitRadius;
                
                if (particle.emitRadius < mMinRadius)
                    particle.currentTime = particle.totalTime;
            }
            else
            {
                var distanceX:Number = particle.x - particle.startX;
                var distanceY:Number = particle.y - particle.startY;
                var distanceScalar:Number = Math.sqrt(distanceX*distanceX + distanceY*distanceY);
                if (distanceScalar < 0.01) distanceScalar = 0.01;
                
                var radialX:Number = distanceX / distanceScalar;
                var radialY:Number = distanceY / distanceScalar;
                var tangentialX:Number = radialX;
                var tangentialY:Number = radialY;
                
                radialX *= particle.radialAcceleration;
                radialY *= particle.radialAcceleration;
                
                var newY:Number = tangentialX;
                tangentialX = -tangentialY * particle.tangentialAcceleration;
                tangentialY = newY * particle.tangentialAcceleration;
                
                particle.velocityX += passedTime * (mGravityX + radialX + tangentialX);
                particle.velocityY += passedTime * (mGravityY + radialY + tangentialY);
                particle.x += particle.velocityX * passedTime;
                particle.y += particle.velocityY * passedTime;
            }
            
            particle.scale += particle.scaleDelta * passedTime;
            particle.rotation += particle.rotationDelta * passedTime;
            
            particle.colorArgb.red   += particle.colorArgbDelta.red   * passedTime;
            particle.colorArgb.green += particle.colorArgbDelta.green * passedTime;
            particle.colorArgb.blue  += particle.colorArgbDelta.blue  * passedTime;
            particle.colorArgb.alpha += particle.colorArgbDelta.alpha * passedTime;
            
            particle.color = particle.colorArgb.toRgb();
            particle.alpha = particle.colorArgb.alpha;
            
            // Animated particle
            var ap:AnimatedPDParticle = particle as AnimatedPDParticle;
            if (ap)
            {
                ap.advanceTime(passedTime);
            }
        }
        
        private function updateEmissionRate():void
        {
            emissionRate = mMaxNumParticles / mLifespan;
        }
        
        override public function advanceTime(passedTime:Number):void 
        {
            var particleIndex:int = 0;
            var particle:AnimatedPDParticle;
            
            // advance existing particles
            
            while (particleIndex < mNumParticles)
            {
                particle = mParticles[particleIndex] as AnimatedPDParticle;
                
                if (particle.currentTime < particle.totalTime)
                {
                    advanceParticle(particle, passedTime);
                    ++particleIndex;
                }
                else
                {
                    if (particleIndex != mNumParticles - 1)
                    {
                        var nextParticle:Particle = mParticles[int(mNumParticles-1)] as Particle;
                        mParticles[int(mNumParticles-1)] = particle;
                        mParticles[particleIndex] = nextParticle;
                    }
                    
                    --mNumParticles;
                    
                    if (mNumParticles == 0 && mEmissionTime == 0)
                        dispatchEvent(new Event(Event.COMPLETE));
                }
            }
            
            // create and advance new particles
            
            if (mEmissionTime > 0)
            {
                var timeBetweenParticles:Number = 1.0 / mEmissionRate;
                mFrameTime += passedTime;
                
                while (mFrameTime > 0)
                {
                    if (mNumParticles < mMaxCapacity)
                    {
                        if (mNumParticles == capacity)
                            raiseCapacity(capacity);
                    
                        particle = mParticles[mNumParticles] as AnimatedPDParticle;
                        initParticle(particle);
                        
                        // particle might be dead at birth
                        if (particle.totalTime > 0.0)
                        {
                            advanceParticle(particle, mFrameTime);
                            ++mNumParticles
                        }
                    }
                    
                    mFrameTime -= timeBetweenParticles;
                }
                
                if (mEmissionTime != Number.MAX_VALUE)
                    mEmissionTime = Math.max(0.0, mEmissionTime - passedTime);
            }
            
            // update vertex data
            
            var vertexID:int = 0;
            var color:uint;
            var alpha:Number;
            var rotation:Number;
            var x:Number, y:Number;
            var xOffset:Number, yOffset:Number;
            var textureWidth:Number = mTexture.width;
            var textureHeight:Number = mTexture.height;
            var region:Rectangle;
            
            for (var i:int=0; i<mNumParticles; ++i)
            {
                vertexID = i << 2;
                particle = mParticles[i] as AnimatedPDParticle;
                region = particle.regions[particle.frameNum];
                color = particle.color;
                alpha = particle.alpha;
                rotation = particle.rotation;
                x = particle.x;
                y = particle.y;
                xOffset = region.width  * particle.scale >> 1;
                yOffset = region.height * particle.scale >> 1;
                
                for (var j:int=0; j<4; ++j)
                    mVertexData.setColorAndAlpha(vertexID+j, color, alpha);
                
                // Set the texture coordinates to display only the current region
                mVertexData.setTexCoords(vertexID, region.x / textureWidth, region.y / textureHeight);
                mVertexData.setTexCoords(vertexID + 1, (region.x + region.width) / textureWidth, region.y / textureHeight);
                mVertexData.setTexCoords(vertexID + 2, region.x / textureWidth, (region.y + region.height) / textureHeight);
                mVertexData.setTexCoords(vertexID + 3, (region.x + region.width) / textureWidth, (region.y + region.height) / textureHeight);
                
                if (rotation)
                {
                    var cos:Number  = Math.cos(rotation);
                    var sin:Number  = Math.sin(rotation);
                    var cosX:Number = cos * xOffset;
                    var cosY:Number = cos * yOffset;
                    var sinX:Number = sin * xOffset;
                    var sinY:Number = sin * yOffset;
                    
                    mVertexData.setPosition(vertexID,   x - cosX + sinY, y - sinX - cosY);
                    mVertexData.setPosition(vertexID+1, x + cosX + sinY, y + sinX - cosY);
                    mVertexData.setPosition(vertexID+2, x - cosX - sinY, y - sinX + cosY);
                    mVertexData.setPosition(vertexID+3, x + cosX - sinY, y + sinX + cosY);
                }
                else 
                {
                    // optimization for rotation == 0
                    mVertexData.setPosition(vertexID,   x - xOffset, y - yOffset);
                    mVertexData.setPosition(vertexID+1, x + xOffset, y - yOffset);
                    mVertexData.setPosition(vertexID+2, x - xOffset, y + yOffset);
                    mVertexData.setPosition(vertexID + 3, x + xOffset, y + yOffset); 
                }
            }
        }
        
        private function parseConfig(config:XML):void
        {
            mEmitterXVariance = parseFloat(config.sourcePositionVariance.attribute("x"));
            mEmitterYVariance = parseFloat(config.sourcePositionVariance.attribute("y"));
            mGravityX = parseFloat(config.gravity.attribute("x"));
            mGravityY = parseFloat(config.gravity.attribute("y"));
            mEmitterType = getIntValue(config.emitterType);
            mMaxNumParticles = getIntValue(config.maxParticles);
            mLifespan = Math.max(0.01, getFloatValue(config.particleLifeSpan));
            mLifespanVariance = getFloatValue(config.particleLifespanVariance);
            mStartSize = getFloatValue(config.startParticleSize);
            mStartSizeVariance = getFloatValue(config.startParticleSizeVariance);
            mEndSize = getFloatValue(config.finishParticleSize);
            mEndSizeVariance = getFloatValue(config.FinishParticleSizeVariance);
            mEmitAngle = deg2rad(getFloatValue(config.angle));
            mEmitAngleVariance = deg2rad(getFloatValue(config.angleVariance));
            mStartRotation = deg2rad(getFloatValue(config.rotationStart));
            mStartRotationVariance = deg2rad(getFloatValue(config.rotationStartVariance));
            mEndRotation = deg2rad(getFloatValue(config.rotationEnd));
            mEndRotationVariance = deg2rad(getFloatValue(config.rotationEndVariance));
            mSpeed = getFloatValue(config.speed);
            mSpeedVariance = getFloatValue(config.speedVariance);
            mRadialAcceleration = getFloatValue(config.radialAcceleration);
            mRadialAccelerationVariance = getFloatValue(config.radialAccelVariance);
            mTangentialAcceleration = getFloatValue(config.tangentialAcceleration);
            mTangentialAccelerationVariance = getFloatValue(config.tangentialAccelVariance);
            mMaxRadius = getFloatValue(config.maxRadius);
            mMaxRadiusVariance = getFloatValue(config.maxRadiusVariance);
            mMinRadius = getFloatValue(config.minRadius);
            mRotatePerSecond = deg2rad(getFloatValue(config.rotatePerSecond));
            mRotatePerSecondVariance = deg2rad(getFloatValue(config.rotatePerSecondVariance));
            mStartColor = getColor(config.startColor);
            mStartColorVariance = getColor(config.startColorVariance);
            mEndColor = getColor(config.finishColor);
            mEndColorVariance = getColor(config.finishColorVariance);
            mBlendFactorSource = getBlendFunc(config.blendFuncSource);
            mBlendFactorDestination = getBlendFunc(config.blendFuncDestination);
            
            // compatibility with future Particle Designer versions
            // (might fix some of the uppercase/lowercase typos)
            
            if (isNaN(mEndSizeVariance))
                mEndSizeVariance = getFloatValue(config.finishParticleSizeVariance);
            if (isNaN(mLifespan))
                mLifespan = Math.max(0.01, getFloatValue(config.particleLifespan));
            if (isNaN(mLifespanVariance))
                mLifespanVariance = getFloatValue(config.particleLifeSpanVariance);
            
            function getIntValue(element:XMLList):int
            {
                return parseInt(element.attribute("value"));
            }
            
            function getFloatValue(element:XMLList):Number
            {
                return parseFloat(element.attribute("value"));
            }
            
            function getColor(element:XMLList):ColorArgb
            {
                var color:ColorArgb = new ColorArgb();
                color.red   = parseFloat(element.attribute("red"));
                color.green = parseFloat(element.attribute("green"));
                color.blue  = parseFloat(element.attribute("blue"));
                color.alpha = parseFloat(element.attribute("alpha"));
                return color;
            }
            
            function getBlendFunc(element:XMLList):String
            {
                var value:int = getIntValue(element);
                switch (value)
                {
                    case 0:     return Context3DBlendFactor.ZERO; break;
                    case 1:     return Context3DBlendFactor.ONE; break;
                    case 0x300: return Context3DBlendFactor.SOURCE_COLOR; break;
                    case 0x301: return Context3DBlendFactor.ONE_MINUS_SOURCE_COLOR; break;
                    case 0x302: return Context3DBlendFactor.SOURCE_ALPHA; break;
                    case 0x303: return Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA; break;
                    case 0x304: return Context3DBlendFactor.DESTINATION_ALPHA; break;
                    case 0x305: return Context3DBlendFactor.ONE_MINUS_DESTINATION_ALPHA; break;
                    case 0x306: return Context3DBlendFactor.DESTINATION_COLOR; break;
                    case 0x307: return Context3DBlendFactor.ONE_MINUS_DESTINATION_COLOR; break;
                    default:    throw new ArgumentError("unsupported blending function: " + value);
                }
            }
        }
        
        public function get emitterType():int { return mEmitterType; }
        public function set emitterType(value:int):void { mEmitterType = value; }

        public function get emitterXVariance():Number { return mEmitterXVariance; }
        public function set emitterXVariance(value:Number):void { mEmitterXVariance = value; }

        public function get emitterYVariance():Number { return mEmitterYVariance; }
        public function set emitterYVariance(value:Number):void { mEmitterYVariance = value; }

        public function get maxNumParticles():int { return mMaxNumParticles; }
        public function set maxNumParticles(value:int):void 
        { 
            maxCapacity = value;
            mMaxNumParticles = maxCapacity; 
            updateEmissionRate(); 
        }

        public function get lifespan():Number { return mLifespan; }
        public function set lifespan(value:Number):void 
        { 
            mLifespan = Math.max(0.01, value);
            updateEmissionRate();
        }

        public function get lifespanVariance():Number { return mLifespanVariance; }
        public function set lifespanVariance(value:Number):void { mLifespanVariance = value; }

        public function get startSize():Number { return mStartSize; }
        public function set startSize(value:Number):void { mStartSize = value; }

        public function get startSizeVariance():Number { return mStartSizeVariance; }
        public function set startSizeVariance(value:Number):void { mStartSizeVariance = value; }

        public function get endSize():Number { return mEndSize; }
        public function set endSize(value:Number):void { mEndSize = value; }

        public function get endSizeVariance():Number { return mEndSizeVariance; }
        public function set endSizeVariance(value:Number):void { mEndSizeVariance = value; }

        public function get emitAngle():Number { return mEmitAngle; }
        public function set emitAngle(value:Number):void { mEmitAngle = value; }

        public function get emitAngleVariance():Number { return mEmitAngleVariance; }
        public function set emitAngleVariance(value:Number):void { mEmitAngleVariance = value; }

        public function get startRotation():Number { return mStartRotation; } 
        public function set startRotation(value:Number):void { mStartRotation = value; }
        
        public function get startRotationVariance():Number { return mStartRotationVariance; } 
        public function set startRotationVariance(value:Number):void { mStartRotationVariance = value; }
        
        public function get endRotation():Number { return mEndRotation; } 
        public function set endRotation(value:Number):void { mEndRotation = value; }
        
        public function get endRotationVariance():Number { return mEndRotationVariance; } 
        public function set endRotationVariance(value:Number):void { mEndRotationVariance = value; }
        
        public function get speed():Number { return mSpeed; }
        public function set speed(value:Number):void { mSpeed = value; }

        public function get speedVariance():Number { return mSpeedVariance; }
        public function set speedVariance(value:Number):void { mSpeedVariance = value; }

        public function get gravityX():Number { return mGravityX; }
        public function set gravityX(value:Number):void { mGravityX = value; }

        public function get gravityY():Number { return mGravityY; }
        public function set gravityY(value:Number):void { mGravityY = value; }

        public function get radialAcceleration():Number { return mRadialAcceleration; }
        public function set radialAcceleration(value:Number):void { mRadialAcceleration = value; }

        public function get radialAccelerationVariance():Number { return mRadialAccelerationVariance; }
        public function set radialAccelerationVariance(value:Number):void { mRadialAccelerationVariance = value; }

        public function get tangentialAcceleration():Number { return mTangentialAcceleration; }
        public function set tangentialAcceleration(value:Number):void { mTangentialAcceleration = value; }

        public function get tangentialAccelerationVariance():Number { return mTangentialAccelerationVariance; }
        public function set tangentialAccelerationVariance(value:Number):void { mTangentialAccelerationVariance = value; }

        public function get maxRadius():Number { return mMaxRadius; }
        public function set maxRadius(value:Number):void { mMaxRadius = value; }

        public function get maxRadiusVariance():Number { return mMaxRadiusVariance; }
        public function set maxRadiusVariance(value:Number):void { mMaxRadiusVariance = value; }

        public function get minRadius():Number { return mMinRadius; }
        public function set minRadius(value:Number):void { mMinRadius = value; }

        public function get rotatePerSecond():Number { return mRotatePerSecond; }
        public function set rotatePerSecond(value:Number):void { mRotatePerSecond = value; }

        public function get rotatePerSecondVariance():Number { return mRotatePerSecondVariance; }
        public function set rotatePerSecondVariance(value:Number):void { mRotatePerSecondVariance = value; }

        public function get startColor():ColorArgb { return mStartColor; }
        public function set startColor(value:ColorArgb):void { mStartColor = value; }

        public function get startColorVariance():ColorArgb { return mStartColorVariance; }
        public function set startColorVariance(value:ColorArgb):void { mStartColorVariance = value; }

        public function get endColor():ColorArgb { return mEndColor; }
        public function set endColor(value:ColorArgb):void { mEndColor = value; }

        public function get endColorVariance():ColorArgb { return mEndColorVariance; }
        public function set endColorVariance(value:ColorArgb):void { mEndColorVariance = value; }
    }
}