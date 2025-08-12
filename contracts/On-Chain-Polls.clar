;; Basic Staking Platform
;; Contract Name: on-chain-polls

;; Constants
(define-constant err-invalid-amount (err u100))
(define-constant err-insufficient-stake (err u101))

;; Map to store user stakes
(define-map stakes principal uint)

;; Total staked in the contract
(define-data-var total-staked uint u0)

;; Function: Stake STX
(define-public (stake (amount uint))
  (begin
    (asserts! (> amount u0) err-invalid-amount)
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set stakes tx-sender
             (+ (default-to u0 (map-get? stakes tx-sender)) amount))
    (var-set total-staked (+ (var-get total-staked) amount))
    (ok true)))

;; Function: Unstake STX
(define-public (unstake (amount uint))
  (let ((current-stake (default-to u0 (map-get? stakes tx-sender))))
    (begin
      (asserts! (>= current-stake amount) err-insufficient-stake)
      (try! (stx-transfer? amount (as-contract tx-sender) tx-sender))
      (map-set stakes tx-sender (- current-stake amount))
      (var-set total-staked (- (var-get total-staked) amount))
      (ok true))))

