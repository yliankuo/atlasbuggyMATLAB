classdef Encoder < handle
    %ENCODER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        rob
        encoder_sub
        
        wheel_dist
        
        timer
        prev_time
        
        enc_ticks_to_m
    end
    
    properties (Access = public)
        d_dist
        wheel_vel
        updated
    end
    
    methods
        function obj = Encoder(rob, topic_name)
            %ENCODER Construct an instance of this class
            obj.rob = rob;
            
            % Initialize ROS subscriber and callback
            obj.encoder_sub = rossubscriber(topic_name, @encoderCallback);
            
            % Initialize attributes
            obj.timer = tic;
            obj.wheel_vel = -1;
            obj.wheel_dist = -1;
            obj.updated = 0;
            obj.prev_time = toc(obj.timer);
            obj.d_dist = 0;
            
            enc_tpr = 1024;
            enc_radius = 0.030825;
            obj.enc_ticks_to_m = 2 * pi * enc_radius / enc_tpr;
            
            function encoderCallback(~, msg)
                %METHOD1 Summary of this method goes here
                %   Detailed explanation goes here
                if obj.wheel_dist == -1
                    ticks = msg.Data;
                    obj.wheel_dist = ticks * obj.enc_ticks_to_m;
                    obj.updated = 0;
                    obj.prev_time = toc(obj.timer);
                else
                    % get difference in distance
                    ticks = msg.Data;
                    obj.d_dist = ticks * obj.enc_ticks_to_m;
                    obj.wheel_dist = obj.wheel_dist + obj.d_dist;

                    % get difference in time
                    cur_time = toc(obj.timer);
                    dt = cur_time - obj.prev_time;
                    obj.prev_time = cur_time;

                    % set new wheel velocity
                    obj.wheel_vel = obj.d_dist/dt;

                    % change updated flag for left wheel
                    obj.updated = 1;
                    obj.rob.updateEncoder();
                end
            end
        end
    end
end

