// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

// Tactical Canvas Hooks for Thunderline Interface
const TacticalHooks = {
  // Tactical Radar Canvas Hook
  tacticalRadar: {
    mounted() {
      const wrapper = this.el;
      const canvas = wrapper.querySelector('canvas');
      const context = canvas.getContext('2d');
      
      // Set up high-DPI canvas
      const ratio = this.getPixelRatio(context);
      this.resizeCanvas(canvas, ratio);
      
      // Store references
      Object.assign(this, { 
        canvas, 
        context, 
        ratio,
        animationFrameRequest: null,
        sweepAngle: 0,
        nodes: [],
        pulses: []
      });
      
      // Set up canvas styles
      canvas.style.background = 'radial-gradient(circle, rgba(0,255,0,0.05) 0%, rgba(0,0,0,0.95) 100%)';
    },

    updated() {
      const { canvas, context } = this;
      
      // Parse data from server
      try {
        const radarData = JSON.parse(this.el.dataset.radarData || '{}');
        this.nodes = radarData.nodes || [];
        this.sweepAngle = radarData.sweepAngle || 0;
        this.systemHealth = radarData.systemHealth || 100;
      } catch (e) {
        console.warn('Failed to parse radar data:', e);
      }
      
      // Cancel previous animation frame
      if (this.animationFrameRequest) {
        cancelAnimationFrame(this.animationFrameRequest);
      }
      
      // Request new animation frame
      this.animationFrameRequest = requestAnimationFrame(() => {
        this.renderRadar();
      });
    },

    destroyed() {
      if (this.animationFrameRequest) {
        cancelAnimationFrame(this.animationFrameRequest);
      }
    },

    // Helper methods
    getPixelRatio(context) {
      const backingStore = context.backingStorePixelRatio ||
        context.webkitBackingStorePixelRatio ||
        context.mozBackingStorePixelRatio ||
        context.msBackingStorePixelRatio ||
        context.oBackingStorePixelRatio ||
        context.backingStorePixelRatio || 1;
      
      return (window.devicePixelRatio || 1) / backingStore;
    },

    resizeCanvas(canvas, ratio) {
      const size = Math.min(canvas.parentElement.clientWidth, canvas.parentElement.clientHeight);
      canvas.width = size * ratio;
      canvas.height = size * ratio;
      canvas.style.width = `${size}px`;
      canvas.style.height = `${size}px`;
    },

    renderRadar() {
      const { canvas, context } = this;
      const centerX = canvas.width / 2;
      const centerY = canvas.height / 2;
      const maxRadius = Math.min(centerX, centerY) * 0.9;

      // Clear canvas
      context.clearRect(0, 0, canvas.width, canvas.height);
      
      // Set up drawing style
      context.strokeStyle = '#00ff00';
      context.fillStyle = '#00ff00';
      context.lineWidth = 2;
      context.font = '12px monospace';

      // Draw radar circles
      this.drawRadarRings(centerX, centerY, maxRadius);
      
      // Draw crosshairs
      this.drawCrosshairs(centerX, centerY, maxRadius);
      
      // Draw sweep
      this.drawRadarSweep(centerX, centerY, maxRadius);
      
      // Draw nodes
      this.drawNodes(centerX, centerY, maxRadius);
      
      // Draw system health indicator
      this.drawHealthIndicator(centerX, centerY, maxRadius);
    },

    drawRadarRings(centerX, centerY, maxRadius) {
      const { context } = this;
      
      // Draw concentric circles
      for (let i = 1; i <= 4; i++) {
        const radius = (maxRadius / 4) * i;
        context.globalAlpha = 0.3;
        context.beginPath();
        context.arc(centerX, centerY, radius, 0, 2 * Math.PI);
        context.stroke();
      }
      context.globalAlpha = 1;
    },

    drawCrosshairs(centerX, centerY, maxRadius) {
      const { context } = this;
      
      context.globalAlpha = 0.3;
      context.beginPath();
      // Vertical line
      context.moveTo(centerX, centerY - maxRadius);
      context.lineTo(centerX, centerY + maxRadius);
      // Horizontal line
      context.moveTo(centerX - maxRadius, centerY);
      context.lineTo(centerX + maxRadius, centerY);
      context.stroke();
      context.globalAlpha = 1;
    },

    drawRadarSweep(centerX, centerY, maxRadius) {
      const { context } = this;
      
      // Animated sweep line
      const sweepX = centerX + Math.cos(this.sweepAngle) * maxRadius;
      const sweepY = centerY + Math.sin(this.sweepAngle) * maxRadius;
      
      // Create gradient for sweep
      const gradient = context.createLinearGradient(centerX, centerY, sweepX, sweepY);
      gradient.addColorStop(0, 'rgba(0, 255, 0, 0.8)');
      gradient.addColorStop(1, 'rgba(0, 255, 0, 0.1)');
      
      context.strokeStyle = gradient;
      context.lineWidth = 3;
      context.beginPath();
      context.moveTo(centerX, centerY);
      context.lineTo(sweepX, sweepY);
      context.stroke();
      
      // Reset stroke style
      context.strokeStyle = '#00ff00';
      context.lineWidth = 2;
    },

    drawNodes(centerX, centerY, maxRadius) {
      const { context } = this;
      
      this.nodes.forEach((node, index) => {
        // Position nodes in a circular pattern
        const angle = (index / this.nodes.length) * 2 * Math.PI;
        const distance = (node.distance || 0.7) * maxRadius;
        const x = centerX + Math.cos(angle) * distance;
        const y = centerY + Math.sin(angle) * distance;
        
        // Set color based on status
        let color = '#00ff00'; // online
        if (node.status === 'warning') color = '#ffaa00';
        else if (node.status === 'critical') color = '#ff0000';
        else if (node.status === 'offline') color = '#666666';
        
        context.fillStyle = color;
        context.strokeStyle = color;
        
        // Draw node
        context.beginPath();
        context.arc(x, y, 4, 0, 2 * Math.PI);
        context.fill();
        
        // Draw pulsing effect for critical nodes
        if (node.status === 'critical') {
          const pulseRadius = 8 + Math.sin(Date.now() * 0.01) * 3;
          context.globalAlpha = 0.3;
          context.beginPath();
          context.arc(x, y, pulseRadius, 0, 2 * Math.PI);
          context.stroke();
          context.globalAlpha = 1;
        }
        
        // Draw node label
        context.fillStyle = color;
        context.fillText(node.name || `N${index + 1}`, x + 8, y + 4);
      });
    },

    drawHealthIndicator(centerX, centerY, maxRadius) {
      const { context } = this;
      
      // Health arc
      const healthRadius = maxRadius * 0.95;
      const healthAngle = (this.systemHealth / 100) * 2 * Math.PI;
      
      // Background arc
      context.globalAlpha = 0.2;
      context.strokeStyle = '#333333';
      context.lineWidth = 8;
      context.beginPath();
      context.arc(centerX, centerY, healthRadius, 0, 2 * Math.PI);
      context.stroke();
      
      // Health arc
      let healthColor = '#00ff00';
      if (this.systemHealth < 80) healthColor = '#ffaa00';
      if (this.systemHealth < 50) healthColor = '#ff0000';
      
      context.globalAlpha = 0.8;
      context.strokeStyle = healthColor;
      context.beginPath();
      context.arc(centerX, centerY, healthRadius, -Math.PI / 2, -Math.PI / 2 + healthAngle);
      context.stroke();
      context.globalAlpha = 1;
      
      // Health percentage text
      context.fillStyle = healthColor;
      context.font = 'bold 16px monospace';
      context.textAlign = 'center';
      context.fillText(`${Math.round(this.systemHealth)}%`, centerX, centerY - 10);
      context.fillText('SYSTEM HEALTH', centerX, centerY + 10);
      context.textAlign = 'left';
      context.font = '12px monospace';
    }
  },

  // Network Topology Canvas Hook  
  networkTopology: {
    mounted() {
      const wrapper = this.el;
      const canvas = wrapper.querySelector('canvas');
      const context = canvas.getContext('2d');
      
      const ratio = this.getPixelRatio(context);
      this.resizeCanvas(canvas, ratio);
      
      Object.assign(this, {
        canvas,
        context,
        ratio,
        animationFrameRequest: null,
        connections: [],
        dataFlow: []
      });
    },

    updated() {
      const { canvas, context } = this;
      
      try {
        const networkData = JSON.parse(this.el.dataset.networkData || '{}');
        this.connections = networkData.connections || [];
        this.dataFlow = networkData.dataFlow || [];
      } catch (e) {
        console.warn('Failed to parse network data:', e);
      }
      
      if (this.animationFrameRequest) {
        cancelAnimationFrame(this.animationFrameRequest);
      }
      
      this.animationFrameRequest = requestAnimationFrame(() => {
        this.renderNetwork();
      });
    },

    destroyed() {
      if (this.animationFrameRequest) {
        cancelAnimationFrame(this.animationFrameRequest);
      }
    },

    getPixelRatio(context) {
      const backingStore = context.backingStorePixelRatio || 1;
      return (window.devicePixelRatio || 1) / backingStore;
    },

    resizeCanvas(canvas, ratio) {
      const rect = canvas.parentElement.getBoundingClientRect();
      canvas.width = rect.width * ratio;
      canvas.height = rect.height * ratio;
      canvas.style.width = `${rect.width}px`;
      canvas.style.height = `${rect.height}px`;
    },

    renderNetwork() {
      const { canvas, context } = this;
      
      context.clearRect(0, 0, canvas.width, canvas.height);
      context.strokeStyle = '#00ff00';
      context.fillStyle = '#00ff00';
      context.lineWidth = 1;
      
      // Draw connections between nodes
      this.connections.forEach(conn => {
        this.drawConnection(conn);
      });
      
      // Draw animated data flow
      this.dataFlow.forEach(flow => {
        this.drawDataFlow(flow);
      });
    },

    drawConnection(connection) {
      const { context, canvas } = this;
      
      const x1 = connection.from.x * canvas.width;
      const y1 = connection.from.y * canvas.height;
      const x2 = connection.to.x * canvas.width;
      const y2 = connection.to.y * canvas.height;
      
      context.globalAlpha = connection.strength || 0.5;
      context.beginPath();
      context.moveTo(x1, y1);
      context.lineTo(x2, y2);
      context.stroke();
      context.globalAlpha = 1;
    },

    drawDataFlow(flow) {
      const { context, canvas } = this;
      
      const x = flow.x * canvas.width;
      const y = flow.y * canvas.height;
      const size = flow.size || 2;
      
      context.fillStyle = flow.color || '#00ff00';
      context.beginPath();
      context.arc(x, y, size, 0, 2 * Math.PI);
      context.fill();
    }
  }
};

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: TacticalHooks  // Add our tactical hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

