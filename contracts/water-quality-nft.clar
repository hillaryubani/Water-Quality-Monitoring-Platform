;; Water Quality Achievement NFT Contract

(define-non-fungible-token water-quality-nft uint)

(define-data-var last-token-id uint u0)

(define-map token-metadata
  { token-id: uint }
  {
    name: (string-utf8 100),
    description: (string-utf8 500),
    achievement-type: (string-ascii 50),
    location: (string-utf8 100),
    date-achieved: uint,
    owner: principal
  }
)

(define-public (mint-achievement (name (string-utf8 100)) (description (string-utf8 500)) (achievement-type (string-ascii 50)) (location (string-utf8 100)))
  (let
    ((new-token-id (+ (var-get last-token-id) u1))
     (recipient tx-sender))
    (try! (nft-mint? water-quality-nft new-token-id recipient))
    (map-set token-metadata
      { token-id: new-token-id }
      {
        name: name,
        description: description,
        achievement-type: achievement-type,
        location: location,
        date-achieved: block-height,
        owner: recipient
      }
    )
    (var-set last-token-id new-token-id)
    (ok new-token-id)
  )
)

(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) (err u403))
    (try! (nft-transfer? water-quality-nft token-id sender recipient))
    (map-set token-metadata
      { token-id: token-id }
      (merge (unwrap-panic (map-get? token-metadata { token-id: token-id }))
             { owner: recipient })
    )
    (ok true)
  )
)

(define-read-only (get-token-metadata (token-id uint))
  (map-get? token-metadata { token-id: token-id })
)

(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? water-quality-nft token-id))
)

