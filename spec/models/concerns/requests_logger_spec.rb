require 'rails_helper'

RSpec.describe RequestsLogger, :model do
  let(:entity){ User.new(id: 1) }
  let(:log_key){ entity.log_key }

  describe '.log_key' do
    subject{ log_key }
    it{ is_expected.to eq 'User_log_storage' }

    context 'with sufix' do
      subject{ entity.log_key 'test' }
      it{ is_expected.to eq 'User_log_storagetest' }
    end
  end

  describe 'data manipulation' do
    before do
      Redis.current.del(log_key)
      Redis.current.del(entity.log_key 'rotation')
    end

    describe '.log_request' do
      subject!{ entity.log_request('test') }

      it{ is_expected.to eq true }
      it 'adds entry' do
        expect(
          Marshal.load Redis.current.lrange(log_key, 0, -1)[0]
        ).to eq [1, 'test']
      end
    end

    describe '.clean_requests_logs' do
      before do
        entity.log_request 'test1'
        entity.log_request 'test2'
      end
      subject!{ entity.clean_requests_logs }

      it 'works' do
        expect(Redis.current.lrange(log_key, 0, -1)).to eq []
      end
    end

    describe '.rotate_requests_logs' do
      before do
        entity.log_request 'test1'
        entity.log_request 'test2'
        entity.log_request 'test3'
      end

      it 'passes correct data' do
        entity.rotate_requests_logs do |entries|
          expect(entries).to eq [[1, "test1"], [1, "test2"], [1, "test3"]]
        end
      end

      it 'clears things up' do
        entity.rotate_requests_logs
        expect(Redis.current.lrange(log_key, 0, -1).length).to eq 0
      end

      context 'when exception interrupts' do
        before do
          begin
            entity.rotate_requests_logs do |entries|
              raise Exception
            end
          rescue Exception
          end
        end

        it 'passes correct data' do
          entity.rotate_requests_logs do |entries|
            expect(entries).to eq [[1, "test1"], [1, "test2"], [1, "test3"]]
          end
        end

        it 'clears main storage' do
          expect(Redis.current.lrange(log_key, 0, -1).length).to eq 0
        end

        context 'when more data arrives' do
          before do
            entity.log_request 'test4'
            entity.log_request 'test5'
            entity.log_request 'test6'
          end

          it 'passes correct data' do
            entity.rotate_requests_logs do |entries|
              expect(entries).to eq [[1, "test1"], [1, "test2"], [1, "test3"]]
            end
          end

          it 'saves additional data' do
            entity.rotate_requests_logs
            entity.rotate_requests_logs do |entries|
              expect(entries).to eq [[1, "test4"], [1, "test5"], [1, "test6"]]
            end
          end
        end
      end
    end
  end
end