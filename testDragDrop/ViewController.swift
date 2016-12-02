//
//  ViewController.swift
//  testDragDrop
//
//  Created by dev_sinu on 2016. 11. 24..
//  Copyright © 2016년 dev_sinu. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var itemsArray : [String]
    var tapDepth = 1
    
    @IBOutlet weak var tableView: UITableView!
    
    required init(coder aDecoder: NSCoder) {
        itemsArray = [String]()
        
        let item1 = "김밥천국"
        let item2 = "중국집"
        let item3 = "일식집"
        let item4 = "선술집"
        let item5 = "양식집"
        let item6 = "아프리카식집"
        let item7 = "북극식집"
        let item8 = "우주식"
        
        itemsArray.append(item1)
        itemsArray.append(item2)
        itemsArray.append(item3)
        itemsArray.append(item4)
        itemsArray.append(item5)
        itemsArray.append(item6)
        itemsArray.append(item7)
        itemsArray.append(item8)
        
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized))
        tableView.addGestureRecognizer(longpress)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        // 오래 누름 제스쳐를 저장하는 변수
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        
        // 오래 누름의 상태를 저장하는 변수 : began, changed, ended 같은 상태가 저장됨
        let state = longPress.state
        
        // long press한 화면상의 위치(좌표값)를 저장하는 변수 (x:11.0, y:13.0), 움직이면 변한다
        let locationInView = longPress.location(in: tableView)
        
        // 선택한 셀의 indexPath를 저장한다([0, 4])
        let indexPath = tableView.indexPathForRow(at: locationInView)
        
        struct My {
            // 스냅샷을 저장할 변수
            static var cellSnapshot : UIView? = nil
            static var cellIsAnimating : Bool = false
            static var cellNeedToShow : Bool = false
        }
        struct Path {
            // long press할 셀의 최초 경로
            static var initialIndexPath : NSIndexPath? = nil
        }
        
        switch state {
        case UIGestureRecognizerState.began: // 셀을 누르기 시작했을때
            if indexPath != nil {
                
                // 셀의 최초 경로를 변수에 저장
                Path.initialIndexPath = indexPath as NSIndexPath?
                
                // 셀의 스냅샷을 변수에 저장
                let cell = tableView.cellForRow(at: indexPath!) as UITableViewCell!
                My.cellSnapshot  = snapshotOfCell(inputView: cell!)
                
                // 셀의 중심 위치를 저장
                var center = cell?.center
                
                // 스냅샷의 위치를 손가락 위치가 아닌 중앙에 생성되도록
                My.cellSnapshot!.center = center!
                // 알파값을 0으로 줌으로 투명하게 만들어 준다
                My.cellSnapshot!.alpha = 0.0
                
                // 스냅샷을 테이블 뷰에 추가함
                tableView.addSubview(My.cellSnapshot!)
                
                // 애니메이션 효과 시작
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    
                    // 스냅샷이 나타날때 손가락 위치로 나타나기 위해서 y값을 조절
                    center?.y = locationInView.y
                    My.cellIsAnimating = true
                    My.cellSnapshot!.center = center!
                    
                    // 스냅샷의 크기를 105%로 만들어서 약간 크게 노출
                    My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    
                    // 스냅샷의 알파값을 변경해서 노출시킴
                    My.cellSnapshot!.alpha = 0.98
                    
                    // 원본 셀을 안보이도록 변경
                    cell?.alpha = 0.0
                    
                }, completion: { (finished) -> Void in
                    if finished {
                        My.cellIsAnimating = false
                        if My.cellNeedToShow {
                            My.cellNeedToShow = false
                            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                                cell?.alpha = 1
                            })
                        } else {
                            // 애니메이션이 끝나면 아이 안보이도록 변경
                            cell?.isHidden = true
                        }
                    }
                })
            }
            
        case UIGestureRecognizerState.changed: // long press를 이동했을 경우
            // 해당 이벤트는 손가락을 이동하는 내내 발생한다!!
            
            // 먼저 스냅샷이 존재 하는가
            if My.cellSnapshot != nil {
                
                // 스냅샷의 좌표를 저장한다
                var center = My.cellSnapshot!.center
                
                // 스냅샷의 y좌표를 손가락이 움직이는 y좌표로 움직인다. x좌표는 움직이지 않는다
                center.y = locationInView.y
                My.cellSnapshot!.center = center
                
                if ((indexPath != nil) && (indexPath != Path.initialIndexPath! as IndexPath)) {
                    // ???? 이건 뭐지, 아마 배열 데이터가 영속 데이터가 아니라서 이 경우엔 의미가 없는 것으로 보임
                    itemsArray.insert(itemsArray.remove(at: Path.initialIndexPath!.row), at: indexPath!.row)
                    
                    // 테이블 뷰의 셀을 변경한다. 한칸한칸 이동할때마다 변경한다고 생각하는 편이 이해가 쉽다
                    // UIGestureRecognizerState.changed 이벤트는 테이블 뷰의 indexPath를 기준으로 일어난다
                    // 즉 손가락의 위치가 indexPath를 변경하는 위치에 오면 그 즉시 실제 테이블 뷰의 셀 위치를 뒤바꾼다
                    // 손가락이 7번째 셀에서 6번째 셀로 올라가는 즉시 6, 7번 셀의 위치를 뒤바꾼다
                    tableView.moveRow(at: Path.initialIndexPath! as IndexPath, to: indexPath!)
                    //                    print("\(Path.initialIndexPath!.row) : \(indexPath!.row)")
                    
                    // long press이벤트가 시작했을때와 끝났을때 indexPath의 값이 변경 될 수 있으므로 이벤트가 종료되는 순간
                    // path.initialIndexPath의 값을 위에서 이미 변경시킨 테이블 뷰의 indexpath값으로 변경한다.
                    // 위의 이벤트로 이미 셀의 위치가 바꼈기 때문에 Path.initialIndexPath를 변경해야 재대로 동작한다.
                    Path.initialIndexPath = indexPath as NSIndexPath?
                }
            }
        default: // long press 이벤트가 종료 되었을때, 손가락을 화면에서 띄었을때
            if Path.initialIndexPath != nil {
                let cell = tableView.cellForRow(at: Path.initialIndexPath! as IndexPath) as UITableViewCell!
                if My.cellIsAnimating {
                    My.cellNeedToShow = true
                } else {
                    cell?.isHidden = false
                    cell?.alpha = 0.0
                }
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    // 스냅샷의 설정을 원래대로 되돌린다
                    My.cellSnapshot!.center = (cell?.center)!
                    My.cellSnapshot!.transform = CGAffineTransform.identity
                    My.cellSnapshot!.alpha = 0.0
                    
                    // 셀의 알파값을 다시 1로 변경
                    cell?.alpha = 1.0
                    
                }, completion: { (finished) -> Void in
                    if finished {
                        // 스냅샷을 제거
                        Path.initialIndexPath = nil
                        My.cellSnapshot!.removeFromSuperview()
                        My.cellSnapshot = nil
                    }
                })
            }
        }
    }
    
    func snapshotOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
//        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
//        cellSnapshot.layer.shadowRadius = 5.0
//        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as UITableViewCell
        cell.selectionStyle = .none
        cell.textLabel?.text = "\(itemsArray[indexPath.row])"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        
        
        if tapDepth < 4 {
            let cellHeight = 44
            
            let changeFrame = CGRect(x: 0, y: 0 + (cellHeight * tapDepth), width: Int(tableView.frame.size.width), height: Int(self.view.frame.size.height) - (cellHeight * tapDepth))
            
            // 애니메이션 효과 시작
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                tableView.frame = changeFrame
            }, completion: { (finished) -> Void in
                if finished {
                    self.tapDepth += 1
                }
            })
            
            let cell = tableView.cellForRow(at: indexPath) as UITableViewCell!
            cell?.backgroundColor = UIColor.blue
            cell?.textLabel?.textColor = UIColor.white
            let snapshot : UIView  = snapshotOfCell(inputView: cell!)
            
            // 셀의 중심 위치를 저장
            let center = self.view.center
            
            print("dddddd=\(center)")
            
            // 스냅샷의 위치를 손가락 위치가 아닌 중앙에 생성되도록
            snapshot.center = center
            
            // 스냅샷을 테이블 뷰에 추가함
            self.view.addSubview(snapshot)
            
            // 애니메이션 효과 시작
            let changeFrame2 = CGRect(x: 0, y: 22 + (cellHeight * (tapDepth-1)), width: Int(snapshot.frame.size.width), height: Int(snapshot.frame.size.height))
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                snapshot.frame = changeFrame2
            }, completion: { (finished) -> Void in
                cell?.backgroundColor = UIColor.white
                cell?.textLabel?.textColor = UIColor.black
            })
        }
    }
    
    
}

