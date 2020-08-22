// SPDX-License-Identifier: MIT

pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;

interface IndexInterface {
  function master() external view returns (address);
}

contract Registry {

  event LogAddChief(address indexed chief);
  event LogAddSigner(address indexed signer);
  event LogRemoveChief(address indexed chief);
  event LogRemoveSigner(address indexed signer);

  IndexInterface public instaIndex;

  mapping (address => bool) public chief;
  mapping (address => bool) public signer;
  mapping (address => address) public poolToken;

  modifier isMaster() {
    require(msg.sender == instaIndex.master(), "not-master");
    _;
  }

  modifier isController() {
    require(chief[msg.sender] || msg.sender == instaIndex.master(), "not-chief");
    _;
  }

  constructor(address _index) public {
    instaIndex = IndexInterface(_index);
  }

  /**
    * @dev Enable New Chief.
    * @param _chief Address of the new chief.
  */
  function enableChief(address _chief) external isMaster {
      require(_chief != address(0), "address-not-valid");
      require(!chief[_chief], "chief-already-enabled");
      chief[_chief] = true;
      emit LogAddChief(_chief);
  }

  /**
    * @dev Disable Chief.
    * @param _chief Address of the existing chief.
  */
  function disableChief(address _chief) external isMaster {
      require(_chief != address(0), "address-not-valid");
      require(chief[_chief], "chief-already-disabled");
      delete chief[_chief];
      emit LogRemoveChief(_chief);
  }

    /**
    * @dev Enable New Signer.
    * @param _signer Address of the new signer.
  */
  function enableSigner(address _signer) external isMaster {
      require(_signer != address(0), "address-not-valid");
      require(!signer[_signer], "signer-already-enabled");
      signer[_signer] = true;
      emit LogAddSigner(_signer);
  }

  /**
    * @dev Disable Signer.
    * @param _signer Address of the existing signer.
  */
  function disableSigneraddress _signer) external isMaster {
      require(_signer != address(0), "address-not-valid");
      require(signer[_signer], "signer-already-disabled");
      delete signer[_signer];
      emit LogRemoveSigner(_signer);
  }
}
