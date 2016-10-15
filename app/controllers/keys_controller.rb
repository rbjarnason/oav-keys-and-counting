# coding: utf-8

# Copyright (C) 2010-2016 Íbúar ses / Citizens Foundation Iceland
# Authors Robert Bjarnason, Gunnar Grimsson & Gudny Maren Valsdottir
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'FileUtils'

PRIVATE_KEY_PATH = Rails.root.join("master_key_pair/private.key")
PUBLIC_KEY_PATH = Rails.root.join("master_key_pair/public.key")
TEMP_PASSPHRASE_FILE_PATH = Rails.root.join("master_key_pair/public.key")
TEMP_OLD_PASSPHRASE_FILE_PATH = Rails.root.join("master_key_pair/public.key")


class KeysController < ApplicationController

  after_filter :log_session_id

  def create_public_private_key_pair
    # We write the passphrases to file so it is not displayed in the command line with ps auxf for example
    File.open(TEMP_PASSPHRASE_FILE_PATH, 'w') { |file| file.write(params[:passphrase]) }
    output = ""
    output += `openssl genpkey -algorithm RSA -out #{PRIVATE_KEY_PATH} -pkeyopt rsa_keygen_bits:2048 -passout file:tempPasswordFile.txt`
    success_1 = $?.success?
    output += `openssl rsa -pubout -in #{PRIVATE_KEY_PATH} -passin file:#{TEMP_PASSPHRASE_FILE_PATH} -out #{PUBLIC_KEY_PATH}`
    success_2 = $?.success?

    FileUtils.rm(TEMP_PASSPHRASE_FILE_PATH)

    if success_1 and success_2
      counting_progress = { status: 'keys_created'}
      BudgetBallot.update(:counting_progress, counting_progress.to_s)
    end

    respond_to do |format|
      format.json { render :json => {:counting_progress => BudgetConfig.first.counting_progress, output: output, success_1: success_1, success_2: success_2 }}
    end
  end

  def change_passphrase
    # We write the passphrases to file so it is not displayed in the command line with ps auxf for example
    File.open(TEMP_PASSPHRASE_FILE_PATH, 'w') { |file| file.write(params[:passphrase]) }
    output = ""
    output += `openssl genpkey -algorithm RSA -out #{PRIVATE_KEY_PATH} -pkeyopt rsa_keygen_bits:2048 -passout file:tempPasswordFile.txt`
    success_1 = $?.success?
    output += `openssl rsa -pubout -in #{PRIVATE_KEY_PATH} -passin file:#{TEMP_PASSPHRASE_FILE_PATH} -out #{PUBLIC_KEY_PATH}`
    success_2 = $?.success?

    FileUtils.rm(TEMP_PASSPHRASE_FILE_PATH)

    if success_1 and success_2
      counting_progress = { status: 'keys_created'}
      BudgetBallot.update(:counting_progress, counting_progress.to_s)
    end

    respond_to do |format|
      format.json { render :json => {:counting_progress => BudgetConfig.first.counting_progress, output: output, success_1: success_1, success_2: success_2 }}
    end
  end

  def boot
    mode = "unexpected"
    if File.file?(PUBLIC_KEY_PATH) and Vote.count>0
      mode = "counting"
    elsif File.file?(PUBLIC_KEY_PATH)
      mode = "changePassphrase"
    elsif Vote.count==0
      mode = "createKeyPair"
    end
    respond_to do |format|
      format.json { render :json => {mode: mode}}
    end
  end

  private

  def is_public_key_here
  end

  def download_public_key
  end

  def test_key_pair
    # Show back to user both encrypted and unecrypted
    # Dulkóðunarpartur kosningar tilbúin
  end

end
