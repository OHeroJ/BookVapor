//
//  MerkleRoot.swift
//  BookCoin
//
//  Created by laijihua on 2018/4/23.
//

import Foundation

indirect enum MerkleRoot {
    case empty
    case node(hash: Data, data: Data?, left: MerkleRoot, right: MerkleRoot)

    init() { self = .empty }

    init(hash: Data) {
        self = MerkleRoot.node(hash: hash, data: nil, left: .empty, right: .empty)
    }
}

extension MerkleRoot {

    static func createParent(leftChild: MerkleRoot, rightChild: MerkleRoot) -> MerkleRoot {
        var leftHash: Data = Data()
        var rightHash: Data = Data()

        switch leftChild {
        case let .node(hash, _, _, _):
            leftHash = hash
        case .empty:
            break
        }
        switch rightChild {
        case let .node(hash, _, _, _):
            rightHash = hash
        case .empty:
            break
        }
        let newHash = (leftHash + rightHash).sha256
        return MerkleRoot.node(hash: newHash, data: nil, left: leftChild, right: rightChild)
    }

    static func buildTree(fromTransactions txns: [Transaction]) -> MerkleRoot {
        var nodeArray = [MerkleRoot]()

        if txns.count == 0 {
            return MerkleRoot.empty
        }

        for tx in txns {
            nodeArray.append(MerkleRoot(hash: tx.tnxHash))
        }

        while nodeArray.count != 1 {
            var tmpArr = [MerkleRoot]()
            while nodeArray.count > 0 {
                let leftNode = nodeArray.removeFirst()
                //Dupe the left node if right node isn't found
                let rightNode = nodeArray.count > 0 ? nodeArray.removeFirst() : leftNode
                tmpArr.append(createParent(leftChild: leftNode, rightChild: rightNode))
            }
            nodeArray = tmpArr
        }
        return nodeArray.first!
    }
}


extension MerkleRoot {
    static func getRootHash(fromTransactions txns: [Transaction]) -> Data {
        let tree = buildTree(fromTransactions: txns)
        var hash = Data()
        switch tree {
        case let .node(hash: rootHash, data: _, left: _, right: _):
            hash = rootHash
        case .empty:
            print("Failed to create tree!")
        }
        return hash.sha256
    }
}
