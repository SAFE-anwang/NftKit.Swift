import BigInt
import EvmKit

class Eip721TransactionDecorator {
    private let userAddress: Address

    init(userAddress: Address) {
        self.userAddress = userAddress
    }
}

extension Eip721TransactionDecorator: ITransactionDecorator {
    public func decoration(from: Address?, to: Address?, value: BigUInt?, contractMethod: ContractMethod?, internalTransactions _: [InternalTransaction], eventInstances: [ContractEventInstance], isLock: Bool) -> TransactionDecoration? {
        guard let from, let to, let value, let contractMethod else {
            return nil
        }

        if let transferMethod = contractMethod as? Eip721SafeTransferFromMethod {
            if from == userAddress {
                return Eip721SafeTransferFromDecoration(
                    contractAddress: to,
                    to: transferMethod.to,
                    tokenId: transferMethod.tokenId,
                    sentToSelf: transferMethod.to == userAddress,
                    tokenInfo: eventInstances.compactMap { $0 as? Eip721TransferEventInstance }.first { $0.contractAddress == to }?.tokenInfo
                )
            }
        }

        if let method = contractMethod as? Eip721SetApprovalForAllMethod {
            if from == userAddress {
                return Eip721SetApprovalForAllDecoration(
                    contractAddress: to,
                    operator: method.operator,
                    approved: method.approved
                )
            }
        }

        return nil
    }
}
