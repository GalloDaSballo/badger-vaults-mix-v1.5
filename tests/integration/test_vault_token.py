from brownie import *
from helpers.constants import MaxUint256


def test_vault_token(vault, want, deployer, randomUser):
    # Deposit
    assert want.balanceOf(deployer) > 0

    depositAmount = int(want.balanceOf(deployer) * 0.8)
    assert depositAmount > 0

    want.approve(vault.address, MaxUint256, {"from": deployer})

    vault.deposit(depositAmount, {"from": deployer})

    shares = vault.balanceOf(deployer)

    # Transfer
    transfer_amount = shares // 2
    vault.transfer(randomUser, transfer_amount, {"from": deployer})

    assert vault.balanceOf(deployer) == shares - transfer_amount
    assert vault.balanceOf(randomUser) == transfer_amount

    # Approve and transferFrom
    transfer_amount = shares - shares // 2
    vault.approve(randomUser, transfer_amount, {"from": deployer})
    vault.transferFrom(deployer, randomUser, transfer_amount, {"from": randomUser})

    assert vault.balanceOf(deployer) == 0
    assert vault.balanceOf(randomUser) == shares