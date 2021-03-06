//
//  SparkView.swift
//  VaCay
//
//  Created by Andre on 7/23/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import Foundation
import UIKit

class SparkView: UIView{
    
    var explosionInLayer:CAEmitterLayer!
    var explosionOutLayer:CAEmitterLayer!
    
    //    MARK: -Initializers
    override init (frame : CGRect) {
        super.init(frame : frame)
        setup()
    }
    
    convenience init () {
        self.init(frame:CGRect.zero)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY);
        self.explosionInLayer.emitterPosition = center;
        self.explosionOutLayer.emitterPosition = center;
    }
    
    //    MARK: -Setup Methods
    func setup(){
        self.clipsToBounds = false
        self.isUserInteractionEnabled = false
        let image = UIImage(named: "spark")
        let particleScale:CGFloat = 0.06
        let particleScaleRange:CGFloat = 0.03

        let explosionOutCell = CAEmitterCell()
        explosionOutCell.name = "explosion";
        explosionOutCell.alphaRange = 0.40;
        explosionOutCell.alphaSpeed = -1.0;
        explosionOutCell.lifetime = 0.8;
        explosionOutCell.lifetimeRange = 0.4;
        explosionOutCell.birthRate = 0;
        explosionOutCell.velocity = 50.00;
        explosionOutCell.velocityRange = 8.00;
        explosionOutCell.contents = image?.cgImage
        explosionOutCell.scale = particleScale
        explosionOutCell.scaleRange = particleScaleRange

        self.explosionOutLayer = CAEmitterLayer()
        self.explosionOutLayer.name = "emitterLayer";
        self.explosionOutLayer.emitterShape = CAEmitterLayerEmitterShape.circle;
        self.explosionOutLayer.emitterMode = CAEmitterLayerEmitterMode.outline;
        self.explosionOutLayer.emitterSize = CGSize(width: 30, height: 0);
        self.explosionOutLayer.emitterCells = [explosionOutCell];
        self.explosionOutLayer.renderMode = CAEmitterLayerRenderMode.oldestFirst;
        self.explosionOutLayer.masksToBounds = false;
        self.layer.addSublayer(self.explosionOutLayer)
        
        let explosionInCell = CAEmitterCell()
        explosionInCell.name = "charge";
        explosionInCell.alphaRange = 0.40;
        explosionInCell.alphaSpeed = -1.0;
        explosionInCell.lifetime = 0.4;
        explosionInCell.lifetimeRange = 0.2;
        explosionInCell.birthRate = 0;
        explosionInCell.velocity = -40.0;
        explosionInCell.velocityRange = 0.00;
        explosionInCell.contents = image?.cgImage
        explosionInCell.scale = particleScale
        explosionInCell.scaleRange = particleScaleRange
        
        self.explosionInLayer = CAEmitterLayer()
        self.explosionInLayer.name = "emitterLayer";
        self.explosionInLayer.emitterShape = CAEmitterLayerEmitterShape.circle;
        self.explosionInLayer.emitterMode = CAEmitterLayerEmitterMode.outline;
        self.explosionInLayer.emitterSize = CGSize(width: 30, height: 0);
        self.explosionInLayer.emitterCells = [explosionInCell];
        self.explosionInLayer.renderMode = CAEmitterLayerRenderMode.oldestFirst;
        self.explosionInLayer.masksToBounds = false;
        self.layer.addSublayer(self.explosionInLayer)
        
    }
    
    func animate () {
        self.explosionInLayer.beginTime = CACurrentMediaTime();
        self.explosionInLayer.setValue(60, forKeyPath: "emitterCells.charge.birthRate")
        let delay = DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delay) {
            self.explode()
        };
    }
    
    func explode () {
        self.explosionInLayer.setValue(0, forKeyPath: "emitterCells.charge.birthRate")
        self.explosionOutLayer.beginTime = CACurrentMediaTime();
        self.explosionOutLayer.setValue(500, forKeyPath: "emitterCells.explosion.birthRate")
        let delay = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delay) {
            self.stop()
        };
    }
    
    func stop () {
        self.explosionInLayer.setValue(0, forKeyPath: "emitterCells.charge.birthRate")
        self.explosionOutLayer.setValue(0, forKeyPath: "emitterCells.explosion.birthRate")
    }
      
    
    
    
    
    
}
